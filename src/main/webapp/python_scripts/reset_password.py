import argparse

parser = argparse.ArgumentParser()
parser.add_argument("name")
parser.add_argument("email")
parser.add_argument("link")
args = parser.parse_args()
from mailer import Mailer

mail = Mailer(email='your_email@gmail.com', password="your_passwrod")
mail.send(receiver=args.email, subject="[www.snirdekel.com]: Reset Password",
          message=f"Hi {args.name}, To Reset Your Password Please Enter The Link:" + "\n" + args.link + "\n" + "Thank You, Snir Dekel")