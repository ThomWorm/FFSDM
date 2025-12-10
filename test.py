import earthaccess

foo = 1
print("foo")
results = earthaccess.search_data(
    short_name="GLDAS_NOAH025_3H",
    version="2.1",
    temporal=("2020-01-01", "2020-01-01"),
    count=1,  # Just get one file
)
print(results)
print("bar")
print(auth)
