clean:
	rm -rf _book

build: clean
	gitbook install
	gitbook build

publish: build
	cd _book && \
		git init && \
		git add -A && \
		git commit -m "update docs" && \
		git push -f https://github.com/syaning/go-pkgs.git master:gh-pages

.SILENT: clean build publish