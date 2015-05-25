build:
	docker build -t ianblenke/flexisip .

run: flexisip/flexisip.conf
	docker run -it --rm ianblenke/flexisip flexisip -c /etc/flexisip/flexisip.conf -s global/debug=true

flexisip/flexisip.conf:
	mkdir -p flexisip
	docker run -it --rm ianblenke/flexisip flexisip --dump-default all > flexisip/flexisip.conf

release:
	which github-release || go get github.com/aktau/github-release
	github-release release \
	  --user ianblenke \
	  --repo docker-flexisip \
	  --tag 1.0.0-268 \
	  --name "Initial build" \
	  --description "A packaging of the first release of flexisip"

