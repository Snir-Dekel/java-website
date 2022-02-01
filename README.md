# java-website
<pre>
☐ java backend
☐ mysql
☐ bootstrap
☐ admin
  ☐ can delete accounts, block accounts permenently and block users by IP
  ☐ can see the last active from each user, by filtering the http request (every http request even for html\css\js files the DB updates itself
  ☐ admin's token changes every http request (when verifying that the admin token is correct, you get a new token)
☐ hashing salting peppering and 10K plus iterations because sha512 once is not suitable for hashing
  ☐ <b>every secret key is in "YOUR_KEY" format for security reasons</b>
☐ when user login with different IP address, his account will be unverified which means he wont be able to login
  ☐ unless he will verify his account through link in his email that the new login is him
☐ profile picture
  ☐ there is an NSFW detector from api so users cant distract other users with their profile picture
☐ each user can save encrypted and zipped files to DB
☐ script files are embedded into jsp files because of server side rendering

</pre>
<hr>

![login screen](https://user-images.githubusercontent.com/66528853/151931835-e9a76f13-2e31-4de0-8662-e9d66462e76e.png)
<hr>

![welcome screen](https://user-images.githubusercontent.com/66528853/151932658-5543bbe5-24b3-4a8a-8d24-ea348ddddf8f.png)
<hr>

![write comment](https://user-images.githubusercontent.com/66528853/151932972-b3bfa5b6-59ec-4072-8ac9-2b7707f5a93a.png)
<hr>

![comment section](https://user-images.githubusercontent.com/66528853/151933867-6a516098-3e58-4b32-8956-1c73820d1615.png)
<hr>

![admin panel](https://user-images.githubusercontent.com/66528853/151934577-ed9f11f8-3530-4be8-9160-a4c3dda9963f.png)
