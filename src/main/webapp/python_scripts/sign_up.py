import argparse

parser = argparse.ArgumentParser()
parser.add_argument("name")
parser.add_argument("email")
parser.add_argument("link")
args = parser.parse_args()
from mailer import Mailer

mail = Mailer(email='your_email@gmail.com', password="your_passwrod")
mail.send(receiver=args.email, subject="[www.snirdekel.com]: Verify Your Email Address",
          message="Hi, " + args.name + "\n" + "To Complete Your Sign Up, Please Verify Your Email:" + "\n" + args.link + "\n" + "Thank You, Snir Dekel")
