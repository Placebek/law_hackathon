import uvicorn
# import ssl

# ssl._create_default_https_context = ssl._create_unverified_context

if __name__ == "__main__":
    uvicorn.run("main:app", host="172.20.10.2", port=8000, reload=True)
