#!/usr/bin/env python3
"""验证合并后的 ISO 文件结构完整性 (ISO9660 + isohybrid + El Torito)"""
import sys

def main(path):
    with open(path, "rb") as f:
        # ISO9660 magic at sector 16 (0x8000)
        f.seek(0x8000)
        magic = f.read(5)
        iso_ok = magic == b"CD001"
        print(f"ISO9660 magic: {magic!r} => {'OK' if iso_ok else 'BAD, not ISO9660!'}")

        # isohybrid MBR signature
        f.seek(0)
        mbr = f.read(512)
        if mbr[510:512] == b"\x55\xaa":
            print("MBR signature: OK (isohybrid)")
        else:
            print("MBR signature: absent")

        # El Torito boot catalog pointer (in PVD, offset 156 from sector 16)
        f.seek(0x8000 + 156)
        boot = f.read(71)
        ptr = boot[0:1]
        torito = "present" if ptr != b"\x00" else "absent/zero"
        print(f"El Torito boot catalog ptr: {ptr.hex()} => {torito}")

        # Volume ID (PVD offset 40)
        f.seek(0x8000 + 40)
        volid = f.read(32).decode("latin1").strip()
        print(f"Volume ID: {volid!r}")

    ok = iso_ok and mbr[510:512] == b"\x55\xaa"
    print("RESULT:", "PASS" if ok else "FAIL")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "merged.iso"))
