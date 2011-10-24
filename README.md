squarepusher downloads Flickr photosets to your local hard disk.

if you are using rubygems, get started with:
    `gem install squarepusher`

then run `squarepusher` and let the help message guide you.

you can easily start by creating a file ~/.squarepusher.yaml with this content:
    key: consumer key
    secret: consumer secret
    token: access token
    token_secret: access token secret
    
then choosing a set and executing:
    `squarepusher <api-key> <secret> <token> grab_set <set-id> <output-dir>`
    
to generate a token, follow these instructions:
[http://www.flickr.com/services/api/auth.howto.mobile.html](http://www.flickr.com/services/api/auth.howto.mobile.html "flickr mobile auth instructions")

dependencies:

  * [flickraw](https://github.com/hanklords/flickraw "flickraw")

 
behaviors of note:

  * photoset and image names are normalized using this: `name.gsub(/[^\w_+\.=-]+/, '-')`