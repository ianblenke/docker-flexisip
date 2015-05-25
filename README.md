# Linphone Flexisip server

This is the [Linphone Flexisip Server](http://www.linphone.org/technical-corner/flexisip/overview).

## Configuration

There is really only a reference .ini style configuration file that is generated at build time which can be overriden with a volume mount.

Rather than do something hokey with a shell script to generate that configuration based on 12-factor environment variables and some kind of packing scheme, I'm punting on this.
Arguably, the configuration is something that something else can take care of. This is meant to be a base image.

That being said, there are a number of ways to go about doing this.

First, here's an example that will pull down the default flexisip.conf file:

    mkdir -p flexisip
    docker run -it --rm ianblenke/flexisip flexisip --dump-default all > flexisip/flexisip.conf

Now you can merrily update the local `flexisip/flexisip.conf` file and start a container that uses it:

    docker run -d --name flexisip --net=host -v `pwd`/flexisip:/etc/flexisip ianblenke/flexisip

If using a host volume seems less than ideal, you can always pull that configuration via a `--volumes-from` from a stopped "data" container:

    docker run -d --name flexisip-data \
               -v /etc/flexisip ianblenke/flexisip true

    docker run -d --name flexisip \
               --net=host --volumes-from flexisip-data ianblenke/flexisip

If you don't mind putting your configuration into a docker image, you could derive your own container image with your own custom configuration from the base image:

    cat <<EOF > Dockerfile.$LOGNAME
    FROM ianblenke/flexisip
    ADD flexisip/flexisip.conf /etc/flexisip/flexisip.conf
    EOF
    docker build -t $LOGNAME/flexisip -f Dockerfile.$LOGNAME .

If you ran that, you could now skip the volume mounting step entirely:

    docker run -d --name flexisip --net=host $LOGNAME/flexisip

The default CMD implied here is:

    docker run -d --name flexisip \
               --net=host \
               -v `pwd`/flexisip:/etc/flexisip ianblenke/flexisip \
               flexisip -c /etc/flexisip/flexisip.conf

Individual settings can also be specified on the command line. Here is an example that sets the global debug flag to true:

    docker run -d --name flexisip \
               --net=host \
               -v `pwd`/flexisip:/etc/flexisip ianblenke/flexisip \
               flexisip -c /etc/flexisip/flexisip.conf -s global/debug=true

For documentation regarding the config file sections and options, see the [Flexisip:module_list](https://wiki.linphone.org/wiki/index.php/Flexisip:module_list) wiki page.

## SNMP Support

There is also preliminary snmp support included. You can grab the example snmpd.conf from the docker image:

    docker run --net=host -it --rm ianblenke/flexisip cat /etc/snmp/snmpd.conf > snmpd.conf

With this, you can specify the custom configuration at runtime:

    docker run -d --name flexisip \
               --net=host \
               -v `pwd`/flexisip:/etc/flexisip \
               -v snmpd.conf:/etc/snmp/snmpd.conf \
               ianblenke/flexisip

After running the server above, it is possible to use this image to snmp query the server:

    docker run -it --rm --net=host -v snmpd.conf:/etc/snmp/snmpd.conf ianblenke/flexisip \
      snmpwalk -m FLEXISIP-MIB  -v 2c -c public \
               -Of localhost FLEXISIP-MIB::flexisipMIB

    docker run -it --rm --net=host -v snmpd.conf:/etc/snmp/snmpd.conf ianblenke/flexisip \
      snmpget -m FLEXISIP-MIB -v 2c -c public \
              -Of localhost FLEXISIP-MIB::flexisipMIB.flexisip.global.debug.0

The running server configuration can be also changed on the fly:

    docker run -it --rm --net=host -v snmpd.conf:/etc/snmp/snmpd.conf ianblenke/flexisip \
      snmpset -m FLEXISIP-MIB  -v 2c -c private \
               localhost FLEXISIP-MIB::flexisipMIB.flexisip.global.debug.0 i 1

For documentation regarding snmp, see the [Flexisip:snmp](https://wiki.linphone.org/wiki/index.php/Flexisip:snmp) wiki page.

