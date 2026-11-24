import json
import tempfile
import unittest
from pathlib import Path
from xml.etree.ElementTree import ParseError

from scripts.check_munit_reports import validate_coverage, validate_reports


class ReportValidationTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)

    def write_report(self, text):
        (self.directory / "TEST-example.xml").write_text(text, encoding="utf-8")

    def test_passing_cases_count_across_suites(self):
        self.write_report(
            '<testsuites><testsuite tests="1"><testcase name="first"/></testsuite>'
            '<testsuite tests="1"><testcase name="second"/></testsuite></testsuites>'
        )
        self.assertEqual(validate_reports(self.directory), 2)

    def test_missing_and_empty_reports_fail(self):
        with self.assertRaises(ValueError):
            validate_reports(self.directory)
        self.write_report('<testsuite tests="0"/>')
        with self.assertRaises(ValueError):
            validate_reports(self.directory)

    def test_skipped_or_failed_cases_do_not_pass(self):
        for outcome, attribute in (("skipped", "skipped"), ("failure", "failures"), ("error", "errors")):
            with self.subTest(outcome=outcome):
                self.write_report(
                    f'<testsuite tests="1" {attribute}="1">'
                    f'<testcase name="case"><{outcome}/></testcase></testsuite>'
                )
                with self.assertRaises(ValueError):
                    validate_reports(self.directory)

    def test_inconsistent_or_invalid_reports_fail(self):
        self.write_report('<testsuite tests="2"><testcase name="one"/></testsuite>')
        with self.assertRaises(ValueError):
            validate_reports(self.directory)
        self.write_report('<testsuite tests="1">')
        with self.assertRaises(ParseError):
            validate_reports(self.directory)

    def test_coverage_requires_threshold_and_executed_processors(self):
        report = self.directory / "coverage.json"
        with self.assertRaises(OSError):
            validate_coverage(report)
        report.write_text(json.dumps({
            "coverage": 90, "requiredApplicationCoverage": 80, "processorCount": 2,
            "coveredProcessorCount": 2
        }), encoding="utf-8")
        self.assertEqual(validate_coverage(report), (90, 80))
        for values in (
            {"coverage": 79, "requiredApplicationCoverage": 80, "processorCount": 2, "coveredProcessorCount": 1},
            {"coverage": 90, "requiredApplicationCoverage": -1, "processorCount": 2, "coveredProcessorCount": 2},
            {"coverage": 90, "requiredApplicationCoverage": 80, "processorCount": 0, "coveredProcessorCount": 0},
            {"coverage": "90", "requiredApplicationCoverage": 80, "processorCount": 2, "coveredProcessorCount": 2},
            {"coverage": 90, "requiredApplicationCoverage": 80, "processorCount": 2, "coveredProcessorCount": 0},
        ):
            with self.subTest(values=values):
                report.write_text(json.dumps(values), encoding="utf-8")
                with self.assertRaises(ValueError):
                    validate_coverage(report)


if __name__ == "__main__":
    unittest.main()
