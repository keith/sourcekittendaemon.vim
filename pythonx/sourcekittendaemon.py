import json
import re
import urllib2
import vim

TOKEN_REGEX = re.compile("<#.*?#>")


def removeTokens(string):
    return re.sub(TOKEN_REGEX, "", string)


def completionDictionary(response):
    try:
        return {
            "word": removeTokens(str(response["sourcetext"])),
            "abbr": str(response["name"]),
        }
    except KeyError:
        return None


def getCompletion(port, path, offset):
    request = urllib2.Request("http://localhost:%d/complete" % port)
    request.add_header("X-Path", path)
    request.add_header("X-Offset", offset)
    response = urllib2.urlopen(request).read()
    return json.loads(response)


def matches(prefix, dictionary):
    if not prefix:
        return True
    word = dictionary["word"]
    return word.startswith(prefix)


def main(prefix, path, offset, port=8081):
    try:
        body = getCompletion(port, path, offset)
        completions = map(completionDictionary, body)
        filtered = [x for x in completions if x and matches(prefix, x)]
        vim.command('let s:result = ' + str(filtered))
    except urllib2.HTTPError, error:
        vim.command("echoerr " + error)
