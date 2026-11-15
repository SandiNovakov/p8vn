import sys


def esc(s):
    out = []
    for c in s:
        if c == "\\":
            out.append("\\\\")
        elif c == '"':
            out.append('\\"')
        elif c.isupper():
            out.append("\\\\" + c.lower())
        else:
            out.append(c)
    return "".join(out)


def convert(md):
    pages, cur = [], []
    for line in md.splitlines():
        if line.strip():
            cur.append(line)
        elif cur:
            pages.append(cur)
            cur = []
    if cur:
        pages.append(cur)

    out = ["script = {"]
    for i, page in enumerate(pages):
        out.append(("," if i else "") + "\t{")
        for j, line in enumerate(page):
            out.append(("\t," if j else "\t") + '\t"' + esc(line) + '"')
        out.append("\t}")
    out.append("}")
    return "\n".join(out)


if __name__ == "__main__":
    src = open(sys.argv[1], encoding="utf-8").read()
    result = convert(src)
    if len(sys.argv) > 2:
        open(sys.argv[2], "w", encoding="utf-8").write(result)
    else:
        print(result)
