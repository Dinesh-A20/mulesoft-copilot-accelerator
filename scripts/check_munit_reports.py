"""Fail when MUnit Surefire reports do not prove a successful test run."""

import argparse
import json
import math
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def local_name(element):
    return element.tag.rsplit("}", 1)[-1]


def validate_reports(report_dir):
    reports = sorted(report_dir.glob("TEST-*.xml"))
    if not reports:
        raise ValueError(f"No MUnit Surefire XML reports in {report_dir}")

    total = 0
    for report in reports:
        root = ET.parse(report).getroot()
        if local_name(root) == "testsuite":
            suites = [root]
        elif local_name(root) == "testsuites":
            suites = [child for child in root if local_name(child) == "testsuite"]
        else:
            raise ValueError(f"Unexpected report root in {report}")
        if not suites:
            raise ValueError(f"No test suites in {report}")

        for suite in suites:
            cases = [child for child in suite if local_name(child) == "testcase"]
            counts = {
                name: int(suite.get(name, "0"))
                for name in ("tests", "failures", "errors", "skipped")
            }
            if counts["tests"] != len(cases) or any(value < 0 for value in counts.values()):
                raise ValueError(f"Inconsistent test counts in {report}")
            outcomes = {"failure": 0, "error": 0, "skipped": 0}
            for case in cases:
                for child in case:
                    name = local_name(child)
                    if name in outcomes:
                        outcomes[name] += 1
            if (counts["failures"], counts["errors"], counts["skipped"]) != (
                outcomes["failure"], outcomes["error"], outcomes["skipped"]
            ):
                raise ValueError(f"Inconsistent test outcomes in {report}")
            if any(outcomes.values()):
                raise ValueError(f"Failed, errored, or skipped tests in {report}")
            total += counts["tests"]

    if total == 0:
        raise ValueError("MUnit reports contain no executed tests")
    return total


def validate_coverage(report_file):
    with report_file.open(encoding="utf-8") as stream:
        report = json.load(stream)
    if not isinstance(report, dict):
        raise ValueError(f"Invalid coverage report in {report_file}")
    coverage = report.get("coverage")
    required = report.get("requiredApplicationCoverage")
    processors = report.get("processorCount")
    covered = report.get("coveredProcessorCount")
    for value in (coverage, required):
        if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
            raise ValueError(f"Invalid coverage percentage in {report_file}")
    if not (0 <= coverage <= 100 and 0 < required <= 100):
        raise ValueError(f"Missing or invalid coverage threshold in {report_file}")
    if isinstance(processors, bool) or not isinstance(processors, int) or processors <= 0:
        raise ValueError(f"No application processors in {report_file}")
    if isinstance(covered, bool) or not isinstance(covered, int) or not (0 < covered <= processors):
        raise ValueError(f"Invalid covered processor count in {report_file}")
    if coverage < required:
        raise ValueError(f"Application coverage {coverage}% is below {required}%")
    return coverage, required


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report_dir", type=Path)
    parser.add_argument("coverage_file", type=Path)
    args = parser.parse_args()
    try:
        total = validate_reports(args.report_dir)
        coverage, required = validate_coverage(args.coverage_file)
    except (OSError, ET.ParseError, ValueError) as error:
        print(f"MUnit report validation failed: {error}", file=sys.stderr)
        return 1
    print(f"Validated {total} executed MUnit test(s); coverage {coverage}% (required {required}%)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
