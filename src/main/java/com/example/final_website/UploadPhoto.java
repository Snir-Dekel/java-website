package com.example.final_website;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.IOUtils;
import org.unbescape.html.HtmlEscape;

import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.image.BufferedImage;
import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;

@WebServlet("/upload-photo")
public class UploadPhoto extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        List<FileItem> multiparts = null;
        try {
            multiparts = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
        }
        catch (FileUploadException e) {
            e.printStackTrace();
        }

        assert multiparts != null;
        String username = HtmlEscape.unescapeHtml(get_username(multiparts));
        String token = get_token(multiparts);
        if (!Functions.user_match_token(username, token)) {
            System.out.println("not user_match_token");
            return;
        }
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        String sql_query = "SELECT COUNT(*) FROM profile_pictures_log WHERE time > NOW() - INTERVAL 1 HOUR AND username = ?";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, username);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                if (Integer.parseInt(resultSet.getString(1)) >= 5) {
                    out.print("<!doctype html>\n" +
                            "\n" +
                            "<html lang=\"en\">\n" +
                            "<head>\n" +
                            "    <title>● Please wait a while</title>\n" +
                            "    <link rel=\"icon\" type=\"image/png\" href=\"logo.png\">\n" +
                            "    <link rel=\"stylesheet\" href=\"styles/svg_animation.css\"/>\n" +
                            "    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js\"></script>\n" +
                            "    <script src=\"https://unpkg.com/tilt.js@1.2.1/dest/tilt.jquery.min.js\"></script>\n" +
                            "\n" +
                            "    <style>\n" +
                            "        * {\n" +
                            "            font-family: Arial, Helvetica, sans-serif;\n" +
                            "            background: rgb(33, 37, 41);\n" +
                            "            color: rgb(225, 225, 225);\n" +
                            "        }\n" +
                            "\n" +
                            "        html, body {\n" +
                            "            max-width: 100%;\n" +
                            "            max-height: 100%;\n" +
                            "            overflow: hidden;\n" +
                            "        }\n" +
                            "\n" +
                            "        .button {\n" +
                            "            font-size: 200%;\n" +
                            "            margin-top: 1rem;\n" +
                            "            transition: all 0.2s;\n" +
                            "            background-color: rgb(58, 61, 71);\n" +
                            "            color: rgb(225, 225, 225);\n" +
                            "            border-radius: 8px;\n" +
                            "            padding: 7px;\n" +
                            "            border: 1px solid #bbb;\n" +
                            "            cursor: pointer;\n" +
                            "\n" +
                            "        }\n" +
                            "\n" +
                            "        .button:hover {\n" +
                            "            background-color: rgb(98, 101, 112);\n" +
                            "        }\n" +
                            "    </style>\n" +
                            "</head>\n" +
                            "<body>\n" +
                            "<div class=\"standup_animation\" style=\"  margin: 0 auto; text-align: center;  width: 50%;\n" +
                            "  \">\n" +
                            "    <h1 style=\"margin-top: 5px;font-weight: bold;\">\n" +
                            "        Please wait a while before changing your profile picture again.\n" +
                            "    </h1>\n" +
                            "    <button onclick=\"window.location.href = '/'\" class=\"button\">\n" +
                            "        Go back\n" +
                            "    </button>\n" +
                            "\n" +
                            "</div>\n" +
                            "<div id=\"sign_div\" style=\"height: 28rem;width: 50rem; margin: 9rem auto auto;\">\n" +
                            "    <svg\n" +
                            "            id=\"sign_element\"\n" +
                            "            width=\"915\"\n" +
                            "            height=\"353\"\n" +
                            "            viewBox=\"0 0 915 353\"\n" +
                            "            fill=\"none\"\n" +
                            "            xmlns=\"http://www.w3.org/2000/svg\"\n" +
                            "    >\n" +
                            "        <g clip-path=\"url(#clip0)\">\n" +
                            "            <g filter=\"url(#filter0_d)\">\n" +
                            "                <path\n" +
                            "                        id=\"path\"\n" +
                            "                        d=\"M179.191 12C159.458 16.9373 141.334 25.5579 123.066 34.4012C92.4225 49.2362 62.3306 65.3793 33.8677 84.1075C29.2562 87.1419 5.27702 99.4617 8.25519 108.403C9.37543 111.767 13.2491 114.119 15.9389 115.982C25.0368 122.285 34.8531 127.528 44.5582 132.81C71.1892 147.304 98.9407 160.353 124.012 177.502C140.854 189.021 159.5 203.355 166.496 223.419C174.705 246.961 169.173 274.57 151.519 292.239C132.2 311.572 100.538 320.09 74.6807 325.841C66.11 327.746 57.4583 329.35 48.7898 330.745C44.5549 331.426 47.7268 331.935 50.3488 331.97C77.5948 332.338 104.492 336.881 131.753 336.985C167.392 337.122 202.974 336.516 238.601 335.926C253.899 335.673 269.113 334.046 284.425 333.976C295.704 333.924 307.087 334.48 318.334 333.475C322.681 333.087 326.961 333.135 331.308 332.973C333.747 332.883 330.964 329.83 330.528 328.738C324.017 312.449 321.41 294.455 319.726 277.137C317.978 259.151 317.972 240.722 319.113 222.695C320.488 201.001 321.255 179.628 321.564 157.886C322.207 112.435 323.011 169.979 323.011 125.344C321.007 112.304 323.011 64.994 323.011 78.7023C323.011 100.899 321.508 106.546 321.508 128.743C321.508 136.943 321.644 161.63 321.644 153.429C321.644 143.604 325.535 131.568 331.753 124.341C356.206 95.9199 398.637 113.554 423.234 131.92C487.392 179.822 498.935 257.776 487.878 332.472C486.828 339.566 484.958 342.728 493.39 341.555C506.757 339.698 521.397 341.555 534.203 341.555C554.471 339.995 575.573 338.379 595.618 336.985C616.665 336.985 638.658 335.982 659.872 332.973C667.116 332.973 673.235 332.973 681.531 332.973C686.264 332.973 691.387 331.07 694.783 331.07C696.328 331.07 691.268 330.933 690.83 328.961C685.457 304.766 687.322 276.862 687.322 252.228C687.322 218.202 691.331 187.425 691.331 153.429C691.331 148.171 688.324 153.429 683.814 150.531C681.195 150.531 679.907 146.542 678.302 144.179C676.184 141.061 674.794 135.374 675.796 131.362C678.302 126.347 680.306 122.823 689.326 122.335C707.868 121.332 707.366 147.912 695.841 149.918C694.337 151.534 693.574 153.166 692.333 151.924C691.4 150.99 690.259 150.991 689.326 151.924C687.318 153.935 691.182 162.244 691.888 164.964C695.917 180.517 694.337 197.42 694.337 213.389C694.337 249.853 689.326 285.976 689.326 322.497C689.326 324.069 688.176 330.89 690.272 330.967C697.211 331.224 703.43 330.967 710.373 330.967C741.757 330.967 774.2 328.961 805.585 328.961C820.544 328.961 835.504 328.961 850.463 328.961C856.478 328.961 854.567 320.376 854.75 315.81C855.054 308.201 856.917 300.772 857.478 293.186C858.215 283.224 858.589 273.231 859.204 263.262C861.086 232.75 861.593 201.823 861.71 171.261C861.758 158.725 861.095 146.037 862.211 133.536C862.494 130.362 860.82 121.625 862.935 124.007C864.531 125.804 863.714 130.3 863.714 132.421C863.714 137.901 863.714 143.379 863.714 148.859C863.714 167.163 861.71 185.347 861.71 203.581C861.71 210.194 861.71 216.806 861.71 223.419C861.71 224.605 861.71 219.094 861.71 218.404C861.71 210.732 863.402 203.79 867.278 197.117C873.093 187.106 879.817 178.38 891.777 176.053C897.271 174.984 901.756 176.499 906.81 176.499\"\n" +
                            "                        stroke=\"white\"\n" +
                            "                        stroke-width=\"15\"\n" +
                            "                        stroke-linecap=\"round\"\n" +
                            "                        stroke-linejoin=\"round\"></path>\n" +
                            "            </g>\n" +
                            "        </g>\n" +
                            "        <defs>\n" +
                            "            <filter\n" +
                            "                    id=\"filter0_d\"\n" +
                            "                    x=\"-3.51056\"\n" +
                            "                    y=\"4.49823\"\n" +
                            "                    width=\"921.821\"\n" +
                            "                    height=\"352.796\"\n" +
                            "                    filterUnits=\"userSpaceOnUse\"\n" +
                            "                    color-interpolation-filters=\"sRGB\"\n" +
                            "            >\n" +
                            "                <feFlood flood-opacity=\"0\" result=\"BackgroundImageFix\"></feFlood>\n" +
                            "                <feColorMatrix\n" +
                            "                        in=\"SourceAlpha\"\n" +
                            "                        type=\"matrix\"\n" +
                            "                        values=\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0\"></feColorMatrix>\n" +
                            "                <feOffset dy=\"4\"></feOffset>\n" +
                            "                <feGaussianBlur stdDeviation=\"2\"></feGaussianBlur>\n" +
                            "                <feColorMatrix\n" +
                            "                        type=\"matrix\"\n" +
                            "                        values=\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0\"></feColorMatrix>\n" +
                            "                <feBlend\n" +
                            "                        mode=\"normal\"\n" +
                            "                        in2=\"BackgroundImageFix\"\n" +
                            "                        result=\"effect1_dropShadow\"></feBlend>\n" +
                            "                <feBlend\n" +
                            "                        mode=\"normal\"\n" +
                            "                        in=\"SourceGraphic\"\n" +
                            "                        in2=\"effect1_dropShadow\"\n" +
                            "                        result=\"shape\"></feBlend>\n" +
                            "            </filter>\n" +
                            "            <clipPath id=\"clip0\">\n" +
                            "                <rect width=\"915\" height=\"353\" fill=\"white\"></rect>\n" +
                            "            </clipPath>\n" +
                            "        </defs>\n" +
                            "    </svg>\n" +
                            "</div>\n" +
                            "<script>\n" +
                            "    let my_path = document.getElementById(\"path\")\n" +
                            "    let sign_element = document.getElementById(\"sign_element\")\n" +
                            "    sign_element.addEventListener(\n" +
                            "        \"mouseover\",\n" +
                            "        function () {\n" +
                            "            sign_element.setAttribute(\"data-sign-element-was-hovered\", \"true\")\n" +
                            "        },\n" +
                            "        false,\n" +
                            "    )\n" +
                            "    my_path.addEventListener(\n" +
                            "        \"mouseover\",\n" +
                            "        function () {\n" +
                            "            document.getElementById(\"sign_element\").style.animationPlayState =\n" +
                            "                \"paused\"\n" +
                            "        },\n" +
                            "        false,\n" +
                            "    )\n" +
                            "    my_path.addEventListener(\n" +
                            "        \"mouseout\",\n" +
                            "        function () {\n" +
                            "            document.getElementById(\"sign_element\").style.animationPlayState =\n" +
                            "                \"running\"\n" +
                            "        },\n" +
                            "        false,\n" +
                            "    )\n" +
                            "    $(\"svg\").tilt({\n" +
                            "        perspective: 550,\n" +
                            "        speed: 2500,\n" +
                            "    })\n" +
                            "</script>\n" +
                            "</body>\n" +
                            "</html>");
                    return;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();

        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }

        try {
            byte[] bytes = new byte[0];
            String file_name = null;
            int image_x = 0, image_y = 0, image_width = 0, image_height = 0;
            for (FileItem multipart : multiparts) {
                if (multipart.getFieldName().equals("file")) {
                    bytes = IOUtils.toByteArray(multipart.getInputStream());
                    file_name = multipart.getName();

                }
                if (multipart.getFieldName().equals("image_coordinates")) {
                    String[] image_coordinates = multipart.getString().split("\\|");
                    image_x = (int) Double.parseDouble(image_coordinates[0]);
                    image_y = (int) Double.parseDouble(image_coordinates[1]);
                    image_width = (int) Double.parseDouble(image_coordinates[2]);
                    image_height = (int) Double.parseDouble(image_coordinates[3]);
                }
            }
            InputStream is = new ByteArrayInputStream(bytes);
            BufferedImage image = ImageIO.read(is);
            BufferedImage croppedImage = image.getSubimage(image_x, image_y, image_width, image_height);
            assert file_name != null;
            String file_extension = file_name.substring(file_name.lastIndexOf('.') + 1);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(croppedImage, file_extension, baos);
            bytes = baos.toByteArray();
            baos.close();
            if (Functions.is_nsfw(croppedImage, file_extension)) {
                System.out.println("NSFW DETECTED!");
                out.print("<!doctype html>\n" +
                        "\n" +
                        "<html lang=\"en\">\n" +
                        "<head>\n" +
                        "    <title>● Can't change profile picture</title>\n" +
                        "    <link rel=\"icon\" type=\"image/png\" href=\"logo.png\">\n" +
                        "    <link rel=\"stylesheet\" href=\"styles/svg_animation.css\"/>\n" +
                        "    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js\"></script>\n" +
                        "    <script src=\"https://unpkg.com/tilt.js@1.2.1/dest/tilt.jquery.min.js\"></script>\n" +
                        "\n" +
                        "    <style>\n" +
                        "        * {\n" +
                        "            font-family: Arial, Helvetica, sans-serif;\n" +
                        "            background: rgb(33, 37, 41);\n" +
                        "            color: rgb(225, 225, 225);\n" +
                        "        }\n" +
                        "\n" +
                        "        html, body {\n" +
                        "            max-width: 100%;\n" +
                        "            max-height: 100%;\n" +
                        "            overflow: hidden;\n" +
                        "        }\n" +
                        "\n" +
                        "        .button {\n" +
                        "            font-size: 200%;\n" +
                        "            margin-top: 1rem;\n" +
                        "            transition: all 0.2s;\n" +
                        "            background-color: rgb(58, 61, 71);\n" +
                        "            color: rgb(225, 225, 225);\n" +
                        "            border-radius: 8px;\n" +
                        "            padding: 7px;\n" +
                        "            cursor: pointer;\n" +
                        "            border: 1px solid #bbb\n" +
                        "        }\n" +
                        "\n" +
                        "        .button:hover {\n" +
                        "            background-color: rgb(98, 101, 112);\n" +
                        "        }\n" +
                        "    </style>\n" +
                        "</head>\n" +
                        "<body>\n" +
                        "<div class=\"standup_animation\" style=\"  margin: 0 auto; text-align: center;  width: 50%;\n" +
                        "  \">\n" +
                        "    <h1 style=\"margin-top: 5px;font-weight: bolder; color: #dd191a\">\n" +
                        "        NSFW content detected!\n" +
                        "    </h1>\n" +
                        "    <h2 style=\"margin-top: 5px;font-weight: normal;color: #ed2c3e\">\n" +
                        "        We detected NSFW content in your uploaded picture. NSFW content is NOT allowed in the website.\n" +
                        "    </h2>\n" +
                        "    <button onclick=\"window.location.href = '/'\" class=\"button\">\n" +
                        "        Go back\n" +
                        "    </button>\n" +
                        "\n" +
                        "</div>\n" +
                        "<div id=\"sign_div\" style=\"height: 28rem;width: 50rem; margin: 9rem auto auto;\">\n" +
                        "    <svg\n" +
                        "            id=\"sign_element\"\n" +
                        "            width=\"915\"\n" +
                        "            height=\"353\"\n" +
                        "            viewBox=\"0 0 915 353\"\n" +
                        "            fill=\"none\"\n" +
                        "            xmlns=\"http://www.w3.org/2000/svg\"\n" +
                        "    >\n" +
                        "        <g clip-path=\"url(#clip0)\">\n" +
                        "            <g filter=\"url(#filter0_d)\">\n" +
                        "                <path\n" +
                        "                        id=\"path\"\n" +
                        "                        d=\"M179.191 12C159.458 16.9373 141.334 25.5579 123.066 34.4012C92.4225 49.2362 62.3306 65.3793 33.8677 84.1075C29.2562 87.1419 5.27702 99.4617 8.25519 108.403C9.37543 111.767 13.2491 114.119 15.9389 115.982C25.0368 122.285 34.8531 127.528 44.5582 132.81C71.1892 147.304 98.9407 160.353 124.012 177.502C140.854 189.021 159.5 203.355 166.496 223.419C174.705 246.961 169.173 274.57 151.519 292.239C132.2 311.572 100.538 320.09 74.6807 325.841C66.11 327.746 57.4583 329.35 48.7898 330.745C44.5549 331.426 47.7268 331.935 50.3488 331.97C77.5948 332.338 104.492 336.881 131.753 336.985C167.392 337.122 202.974 336.516 238.601 335.926C253.899 335.673 269.113 334.046 284.425 333.976C295.704 333.924 307.087 334.48 318.334 333.475C322.681 333.087 326.961 333.135 331.308 332.973C333.747 332.883 330.964 329.83 330.528 328.738C324.017 312.449 321.41 294.455 319.726 277.137C317.978 259.151 317.972 240.722 319.113 222.695C320.488 201.001 321.255 179.628 321.564 157.886C322.207 112.435 323.011 169.979 323.011 125.344C321.007 112.304 323.011 64.994 323.011 78.7023C323.011 100.899 321.508 106.546 321.508 128.743C321.508 136.943 321.644 161.63 321.644 153.429C321.644 143.604 325.535 131.568 331.753 124.341C356.206 95.9199 398.637 113.554 423.234 131.92C487.392 179.822 498.935 257.776 487.878 332.472C486.828 339.566 484.958 342.728 493.39 341.555C506.757 339.698 521.397 341.555 534.203 341.555C554.471 339.995 575.573 338.379 595.618 336.985C616.665 336.985 638.658 335.982 659.872 332.973C667.116 332.973 673.235 332.973 681.531 332.973C686.264 332.973 691.387 331.07 694.783 331.07C696.328 331.07 691.268 330.933 690.83 328.961C685.457 304.766 687.322 276.862 687.322 252.228C687.322 218.202 691.331 187.425 691.331 153.429C691.331 148.171 688.324 153.429 683.814 150.531C681.195 150.531 679.907 146.542 678.302 144.179C676.184 141.061 674.794 135.374 675.796 131.362C678.302 126.347 680.306 122.823 689.326 122.335C707.868 121.332 707.366 147.912 695.841 149.918C694.337 151.534 693.574 153.166 692.333 151.924C691.4 150.99 690.259 150.991 689.326 151.924C687.318 153.935 691.182 162.244 691.888 164.964C695.917 180.517 694.337 197.42 694.337 213.389C694.337 249.853 689.326 285.976 689.326 322.497C689.326 324.069 688.176 330.89 690.272 330.967C697.211 331.224 703.43 330.967 710.373 330.967C741.757 330.967 774.2 328.961 805.585 328.961C820.544 328.961 835.504 328.961 850.463 328.961C856.478 328.961 854.567 320.376 854.75 315.81C855.054 308.201 856.917 300.772 857.478 293.186C858.215 283.224 858.589 273.231 859.204 263.262C861.086 232.75 861.593 201.823 861.71 171.261C861.758 158.725 861.095 146.037 862.211 133.536C862.494 130.362 860.82 121.625 862.935 124.007C864.531 125.804 863.714 130.3 863.714 132.421C863.714 137.901 863.714 143.379 863.714 148.859C863.714 167.163 861.71 185.347 861.71 203.581C861.71 210.194 861.71 216.806 861.71 223.419C861.71 224.605 861.71 219.094 861.71 218.404C861.71 210.732 863.402 203.79 867.278 197.117C873.093 187.106 879.817 178.38 891.777 176.053C897.271 174.984 901.756 176.499 906.81 176.499\"\n" +
                        "                        stroke=\"white\"\n" +
                        "                        stroke-width=\"15\"\n" +
                        "                        stroke-linecap=\"round\"\n" +
                        "                        stroke-linejoin=\"round\"></path>\n" +
                        "            </g>\n" +
                        "        </g>\n" +
                        "        <defs>\n" +
                        "            <filter\n" +
                        "                    id=\"filter0_d\"\n" +
                        "                    x=\"-3.51056\"\n" +
                        "                    y=\"4.49823\"\n" +
                        "                    width=\"921.821\"\n" +
                        "                    height=\"352.796\"\n" +
                        "                    filterUnits=\"userSpaceOnUse\"\n" +
                        "                    color-interpolation-filters=\"sRGB\"\n" +
                        "            >\n" +
                        "                <feFlood flood-opacity=\"0\" result=\"BackgroundImageFix\"></feFlood>\n" +
                        "                <feColorMatrix\n" +
                        "                        in=\"SourceAlpha\"\n" +
                        "                        type=\"matrix\"\n" +
                        "                        values=\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0\"></feColorMatrix>\n" +
                        "                <feOffset dy=\"4\"></feOffset>\n" +
                        "                <feGaussianBlur stdDeviation=\"2\"></feGaussianBlur>\n" +
                        "                <feColorMatrix\n" +
                        "                        type=\"matrix\"\n" +
                        "                        values=\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0\"></feColorMatrix>\n" +
                        "                <feBlend\n" +
                        "                        mode=\"normal\"\n" +
                        "                        in2=\"BackgroundImageFix\"\n" +
                        "                        result=\"effect1_dropShadow\"></feBlend>\n" +
                        "                <feBlend\n" +
                        "                        mode=\"normal\"\n" +
                        "                        in=\"SourceGraphic\"\n" +
                        "                        in2=\"effect1_dropShadow\"\n" +
                        "                        result=\"shape\"></feBlend>\n" +
                        "            </filter>\n" +
                        "            <clipPath id=\"clip0\">\n" +
                        "                <rect width=\"915\" height=\"353\" fill=\"white\"></rect>\n" +
                        "            </clipPath>\n" +
                        "        </defs>\n" +
                        "    </svg>\n" +
                        "</div>\n" +
                        "<script>\n" +
                        "    let my_path = document.getElementById(\"path\")\n" +
                        "    let sign_element = document.getElementById(\"sign_element\")\n" +
                        "    sign_element.addEventListener(\n" +
                        "        \"mouseover\",\n" +
                        "        function () {\n" +
                        "            sign_element.setAttribute(\"data-sign-element-was-hovered\", \"true\")\n" +
                        "        },\n" +
                        "        false,\n" +
                        "    )\n" +
                        "    my_path.addEventListener(\n" +
                        "        \"mouseover\",\n" +
                        "        function () {\n" +
                        "            document.getElementById(\"sign_element\").style.animationPlayState =\n" +
                        "                \"paused\"\n" +
                        "        },\n" +
                        "        false,\n" +
                        "    )\n" +
                        "    my_path.addEventListener(\n" +
                        "        \"mouseout\",\n" +
                        "        function () {\n" +
                        "            document.getElementById(\"sign_element\").style.animationPlayState =\n" +
                        "                \"running\"\n" +
                        "        },\n" +
                        "        false,\n" +
                        "    )\n" +
                        "    $(\"svg\").tilt({\n" +
                        "        perspective: 550,\n" +
                        "        speed: 2500,\n" +
                        "    })\n" +
                        "</script>\n" +
                        "</body>\n" +
                        "</html>");
                return;
            }
            String saved_file_hash = org.apache.commons.codec.digest.DigestUtils.sha512Hex(bytes);



            try {
                if (Functions.can_delete_profile_picture(username)) {
                    Functions.delete_old_photo(username);
                }
                String sql_query2 = "INSERT INTO profile_pictures (profile_picture_name, profile_picture_type, profile_picture) VALUES (?, ? ,?)";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(url, sql_user, sql_pass);
                preparedStatement = connection.prepareStatement(sql_query2);
                preparedStatement.setString(1, saved_file_hash);
                preparedStatement.setString(2, file_extension);

                preparedStatement.setBlob(3, new ByteArrayInputStream(bytes));
                try {
                    preparedStatement.executeUpdate();
                }
                catch (Exception ignored) {

                }

                String sql_query3 = "INSERT INTO profile_pictures_log (username, time) VALUES (?, NOW())";
                preparedStatement = connection.prepareStatement(sql_query3);
                preparedStatement.setString(1, username);
                preparedStatement.executeUpdate();

                Functions.update_user_profile_picture_name(username, saved_file_hash);


            }
            catch (Exception e) {
                e.printStackTrace();
            }
            finally {
                Functions.close_sql_connection(connection, preparedStatement, resultSet);
                is.close();
            }


            System.out.println("profile picture saved in database as " + saved_file_hash);

        }
        catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("/");

    }

    String get_username(List<FileItem> parts) {
        for (FileItem part : parts) {
            if (part.getFieldName().equals("username")) {
                return part.getString();
            }
        }
        return "";
    }

    String get_token(List<FileItem> parts) {
        for (FileItem part : parts) {
            if (part.getFieldName().equals("token")) {
                return part.getString();
            }
        }
        return "";
    }

}
