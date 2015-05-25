build:
	docker build -t ianblenke/flexisip .

run: flexisip/flexisip.conf
	docker run -it --rm ianblenke/flexisip flexisip -c /etc/flexisip/flexisip.conf -s global/debug=true

flexisip/flexisip.conf:
	mkdir -p flexisip
	docker run -it --rm ianblenke/flexisip flexisip --dump-default all > flexisip/flexisip.conf

