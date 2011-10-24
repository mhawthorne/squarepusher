squarepusher downloads Flickr photosets to your local hard disk.

if you are using rubygems, get started with:
    `gem install squarepusher`

you can easily start by creating a file ~/.squarepusher.yaml with this content:

    key: consumer key
    secret: consumer secret
    token: access token
    token_secret: access token secret

then run `squarepusher` with the action that you're interested in, foe example:
    
    `squarepusher list_sets`
    
lists all of your flickr photosets.
    
there are a few different ways to generate an access token.  assuming you have a consumer key, here is one way:
[http://www.flickr.com/services/api/auth.howto.mobile.html](http://www.flickr.com/services/api/auth.howto.mobile.html "flickr mobile auth instructions")

dependencies:

  * [flickraw](https://github.com/hanklords/flickraw "flickraw")

 
behaviors of note:

  * photoset and image names are normalized using this: `name.gsub(/[^\w_+\.=-]+/, '-')`