import argparse

parser = argparse.ArgumentParser()
parser.add_argument("name")
parser.add_argument("email")
parser.add_argument("link")
args = parser.parse_args()
from mailer import Mailer

mail = Mailer(email='your_email@gmail.com', password="your_passwrod")
mail.send(receiver=args.email, subject="[www.snirdekel.com]: Verify Account Login From New Location",
          message="Hi, " + args.name + "\n" + "We Detected A Login To www.snirdekel.com From New A Location, Please Enter The Link And Try To Login Again" + "\n" + args.link + "\n" + "Thank You, Snir Dekel")