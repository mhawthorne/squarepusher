squarepusher downloads Flickr photosets to your local hard disk.

if you are using rubygems, get started with:
`gem install squarepusher`.

then run `squarepusher` and let the help message guide you.

you can easily start be executing:
`squarepusher <api-key> <secret> <token> list_sets`
    
then choosing a set and executing:
`squarepusher <api-key> <secret> <token> grab_set <set-id> <output-dir>`
    
to generate a token, follow these instructions:
[http://www.flickr.com/services/api/auth.howto.mobile.html](http://www.flickr.com/services/api/auth.howto.mobile.html "flickr mobile auth instructions")

using the mobile auth approach is best here, since the idea is that you generate a one-time token that can be stored on a device. in this case the device
can just be the hard drive of your laptop, or for me, an item in my bash history.

dependencies
 * [flickraw](https://github.com/hanklords/flickraw "flickraw") (awesome project)
 
behaviors of note:
 * photoset and image names are normalized using this: `name.gsub(/[^\w_+\.=-]+/, '-')`