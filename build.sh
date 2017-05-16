rm -rf _book
gitbook install
gitbook build
cd _book
git init
git add -A
git commit -m "update docs"
git push -f https://github.com/syaning/go-pkgs.git master:gh-pages