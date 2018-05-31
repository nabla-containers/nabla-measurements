FROM python:3.5.2 

COPY tornado_main.py /usr/src/myapp/
COPY tornado.site-packages /usr/local/lib/python3.5/site-packages 
WORKDIR /usr/src/myapp

EXPOSE 5000

CMD ["python3.5","tornado_main.py"]