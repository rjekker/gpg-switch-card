# gpg-switch-card
Script that facilitates switching out smart cards for GPG


When using multiple smart cards (like yubikeys) with GPG, switching them is annoying because GPG will keep asking for the previous card you plugged in. To fix this, you need to remove some specific files for the keys on the other card, and you can find those files by looking up keygrips.. it's all very complicated.

Fortunately, this script will let you choose one of your GPG id's and it will help you remove the secret key files for that card.

Of course you should ONLY run this script if you know what you are doing!!!
