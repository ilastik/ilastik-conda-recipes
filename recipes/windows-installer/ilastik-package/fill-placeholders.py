import re


if __name__ == "__main__":
    with open('../ilastik-meta/ilastik/ilastik/__init__.py', 'r') as f:
        version_line = re.findall("__version_info__[ ]*=[ ]*\((?P<version>[a-z0-9\' ,]+)\)", f.read())[0]
    version_str = version_line.groupdict()["version"]
    version_str = ".".join([x.strip(' \'"') for x in version_str.split(',')])

    print(f"found version {version_str}")

    with open('../package/ilastik.iss.in', 'r') as f:
        content = f.read()

    content = re.sub("@VERSION@", version_str, content, count=0)

    with open('../package/ilastik.iss', 'w') as f:
        f.write(content)
