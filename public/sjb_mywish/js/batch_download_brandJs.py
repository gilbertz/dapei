#wget implied by python
#!/usr/bin/python
import sys, urllib

def reporthook(*a):
    print a

def main():
    brands = open('./brand.txt');
    for brand in brands:
	loc = brand.find('\"',1);
	url = 'http://myrunway.com.cn/mywish/js/brand/' + brand[1:loc]
	print url
        i = url.rfind('/')
        file = url[i+1:]
        print url, "->", file
        urllib.urlretrieve(url, file, reporthook)

if __name__ == '__main__':
    main()
