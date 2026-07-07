r"""Script to bundle CEL policy conformance tests.

Each CEL policy conformance test is a self-contained directory containing an
optional environment, a policy, and a test suite. This script
bundles them all together into a single multidocument YAML file to simplify file
loading.

Intended to be called via bazel rule.

Format:

```
# config.yaml
{environment}
---
# policy.yaml
{policy}
---
# tests.yaml
{test}
```

Usage:
  bazel run //third_party/cel/policy/bazel:bundle -- \
    --environment=<environment file> \
    --policy=<policy file> \
    --test=<test file> \
    --output=<path to output file>
"""

import argparse
from collections.abc import Sequence
import os
import sys


def _read_and_format_section(path: str) -> bytes:
  with open(path, "rb") as f:
    content = f.read().rstrip()
  comment = f"# {os.path.basename(path)}".encode("utf-8")
  return comment + b"\n" + content


def bundle(environment: str | None, policy: str, test: str) -> bytes:
  sections = []
  if environment:
    sections.append(_read_and_format_section(environment))
  sections.append(_read_and_format_section(policy))
  sections.append(_read_and_format_section(test))
  return b"\n---\n".join(sections) + b"\n"


def main(argv: Sequence[str]) -> None:
  parser = argparse.ArgumentParser(
      description="Bundle CEL policy conformance tests."
  )
  parser.add_argument(
      "--environment",
      help="Path to the environment file.",
      required=False,
      default=None,
  )
  parser.add_argument(
      "--policy",
      help="Path to the policy file.",
      required=True,
  )
  parser.add_argument(
      "--test",
      help="Path to the test file.",
      required=True,
  )
  parser.add_argument(
      "--output",
      help="Path to the output file.",
      required=True,
  )
  args = parser.parse_args(argv[1:])
  bundled_content = bundle(args.environment, args.policy, args.test)
  with open(args.output, "wb") as f:
    f.write(bundled_content)


if __name__ == "__main__":
  main(sys.argv)
