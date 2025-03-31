import uvicorn
# import ssl

# ssl._create_default_https_context = ssl._create_unverified_context

if __name__ == "__main__":
    uvicorn.run("main:app", host="192.168.43.31", port=8000, reload=True)
