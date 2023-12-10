##* build     - use hugo to build the site
HUGOARGS := --gc --minify
build: public/index.html
public/index.html: hugo.yaml makefile $(shell find content/ -type f)
	git submodule update --init --recursive
	hugo --ignoreCache $(HUGOARGS)

##  serve     - build and serve from memory
serve:
	git submodule update --init --recursive
	hugo serve --disableFastRender $(HUGOARGS)

##  new       - write a new blog post
new:
	@read -p 'Enter path: ' -ei 'posts/$(shell date +%Y)/newpost/' path && \
	hugo new "$$path/index.md"

##  deploy    - build and deploy the site
DEPLOY 		:= 
RSYNCARGS :=
deploy: clean build
	rsync --archive $(RSYNCARGS) --chown=root:root public/ $(DEPLOY)

##  dist      - create a compressed archive of built site
VERSION = $(shell printf "r%s-g%s" "$$(git rev-list --count HEAD)" "$$(git rev-parse --short HEAD)")
ARCHIVE = homepage-$(VERSION).tar.gz
dist: $(ARCHIVE)
$(ARCHIVE): clean build
	tar czf $@ -C public/ .

##  clean     - remove built public/ site
clean:
	rm -rf public/

##  veryclean - use git to clean files and deinit all submodules
veryclean: clean
	git submodule deinit --all --force
	git clean -fdx
