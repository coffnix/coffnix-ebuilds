#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

regex = r'(\d+(?:[\.-]\d+)+)'

async def generate(hub, **pkginfo):
    download_url="https://www.webkitgtk.org/releases/"
    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)
    compression = ".xz"

    versions = {Version(re.findall(regex, a.contents[0])[0]): a for a in soup if re.findall(regex, a.contents[0]) and a.contents[0].endswith(compression)}

    # New dependencies are in 2.40.x series, including: unifdef, gi-docgen and >=gstreamer-1.20
    stable = [Version(re.findall(regex, a.contents[0])[0]) for a in soup if re.findall(regex, a.contents[0]) and a.contents[0].startswith('LATEST-STABLE')][0]

    version_max = Version("2.39")
    stable = max(v for v in versions.keys() if v < version_max)

    tarball = versions[stable].get('href')

    artifact = hub.pkgtools.ebuild.Artifact(url=download_url + tarball)

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=stable.public,
        artifacts=[artifact],
        soname="4/0"
    )
    ebuild.push()


#vim: ts=4 sw=4 noet
