//
// // deploy.js
// var Client = require('ftp');
// var chalk = require('chalk');
// var fs = require('fs');
// var path = require('path');
// var ENV = process.env;
// var BUILD_PATH = path.resolve(__dirname, ENV.FTP_BUILD_PATH || 'build');
// var TARGET_PATH = ENV.FTP_SERVER_PATH;
// var USERNAME = ENV.FTP_USERNAME;
// var PASSWORD = ENV.FTP_PASSWORD;
// var HOST = ENV.FTP_SERVER_HOST;
// var PORT = ENV.FTP_SERVER_PORT || 21;
//
// var client = new Client();
// client.on('greeting', function(msg) {
//     console.log(chalk.green('greeting'), msg);
// });
// client.on('ready', function() {
//     client.list(TARGET_PATH, function(err, serverList) {
//         console.log(chalk.green('get list from server.'));
//         /*
//          * somehow you need to workout what files you are going to upload
//          * you may need to compare with what already exists in the server
//          */
//         var uploadList = /* your upload list */
//         var total = uploadList.length;
//         var uploadCount = 0;
//         var errorList = [];
//         uploadList.forEach(function(file) {
//             console.log(chalk.blue('start'), file.local + chalk.grey(' --> ') + file.target);
//             client.put(file.local, file.target, function(err) {
//                 uploadCount++;
//                 if (err) {
//                     console.error(chalk.red('error'), file.local + chalk.grey(' --> ') + file.target);
//                     console.error(err.message);
//                     throw err;
//                 } else {
//                     console.info(chalk.green('success'), file.local + chalk.grey(' --> ') + file.target, chalk.grey('( ' + uploadCount + '/' + total + ' )'));
//                 }
//
//                 if (uploadCount === total) {
//                     client.end();
//                     if (errorList.length === 0) {
//                         console.info(chalk.green('All files uploaded!'));
//                     } else {
//                         console.log(chalk.red('Failed files:'));
//                         errorList.forEach(function(file) {
//                             console.log(file.local + chalk.grey(' --> ') + file.target);
//                         });
//                         throw 'Total Failed: ' + errorList.length;
//                     }
//                 }
//             });
//         });
//     });
// });
// // connect to localhost:21 as anonymous
// client.connect({
//     host: HOST,
//     port: PORT,
//     user: USERNAME,
//     password: PASSWORD,
// });

#!/bin/bash
gitLastCommit=$(git show --summary --grep="Merge pull request")
if [[ -z "$gitLastCommit" ]]
    then
lastCommit=$(git log --format="%H" -n 1)
else
echo "We got a Merge Request!"
#take the last commit and take break every word into an array
arr=($gitLastCommit)
#the 5th element in the array is the commit ID we need. If git log changes, this breaks. :(
    lastCommit=${arr[4]}
        fi
echo $lastCommit

filesChanged=$(git diff-tree --no-commit-id --name-only -r $lastCommit)
if [ ${#filesChanged[@]} -eq 0 ]; then
echo "No files to update"
else
for f in $filesChanged
    do
        #do not upload these files that aren't necessary to the site
if [ "$f" != ".travis.yml" ] && [ "$f" != "deploy.sh" ] && [ "$f" != "test.js" ] && [ "$f" != "package.json" ]
    then
echo "Uploading $f"
curl --ftp-create-dirs -T $f -u $FTP_USER:$FTP_PASS ftp://hexup.co/$f
    fi
done
fi