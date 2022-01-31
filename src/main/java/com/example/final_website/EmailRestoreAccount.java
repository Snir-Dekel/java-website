package com.example.final_website;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/email-restore-account")
public class EmailRestoreAccount extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        String email = request.getParameter("email");
        String username = Functions.get_username(email);
        if (username == null) {
            out.print("This email does not registered in the website or not deleted");
            return;
        }
                    String gRecaptchaResponse = request.getParameter("g-recaptcha-response");
            boolean verify = VerifyRecaptcha.verify(gRecaptchaResponse);
            if (!verify) {
                out.print("recaptcha failed");
                return;
            }
            String ip = Functions.getClientIp(request);
            if (!Functions.can_send_email(email, ip, "password")) {
                out.print("Please wait a while, you are sending emails too fast");
                return;
            }

        try {
            System.out.println(email);
            if (Functions.can_send_email(email, ip, "restore")) {
                Functions.update_verification_code(email, Functions.get_verification_code(email));
                Runtime.getRuntime().exec("cmd /c PYTHON_PATH\\python.exe \"final_website\\src\\main\\webapp\\python_scripts\\restore_account.py\" " + '"' + username + '"' + " " + email + " " + '"' + request.getServerName() + "/restore-account?verificationCode=" + Functions.get_verification_code(email) + "&email=" + email + '"');
                Functions.insert_send_email(email, ip, "restore");
            }
            else {
                System.out.println("can_send_email returned false");
                Functions.insert_send_email(email, ip, "restore");

                out.print("Please wait a while, you are sending emails too fast");
                return;
            }
        }

        catch (Exception e) {
            e.printStackTrace();
        }
        out.print("Check Your Email");

        out.close();
    }
}
