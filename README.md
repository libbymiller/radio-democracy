radio-popular
=============

Example application using the radiodan gem based on radiodan_example and an idea by Richard Sewell.

Each radio has three buttons: Try, Thumbs Up, Thumbs Down.

Try switches to a different program from the available set (interpreted as a random one).

Thumbs Up gives the current program an upvote (and it keeps playing).

Thumbs Down gives the current program a downvote, and switches to the program that this
listener has not heard which has the highest score (upvotes - downvotes). 

When a program ends, the radio also switches to that highest-score program.


## Getting started

- Download and install [Vagrant](http://downloads.vagrantup.com/)
- git clone https://github.com/libbymiller/radio-democracy.git
- cd radio-democracy
- `$ vagrant up`
- Shell into the virtual machine `$ vagrant ssh`
- Change to the application directory, mounted as `$ cd /vagrant`
- Install the dependencies for the app `$ bundle install`
- Start the radio application `$ bin/start`

After a few moments the radio should start playing (it downloads some files first from the BBC podcasts site: http://www.bbc.co.uk/podcasts). 

## Commands:

Vote up: curl -X POST -i http://localhost:3030/up
Vote down: curl -X POST -i http://localhost:3030/down
Try (random): curl -X POST -i http://localhost:3030/try



