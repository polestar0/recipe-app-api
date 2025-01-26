"""
Sample tests
"""

from django.test import SimpleTestCase

from app import calc 
# what is mocking : studydeep 


# all the  test function name should be start with test_name else wont be picked 
# the test file "tests.py" name should not be same as any other folder or function named tests create issue in import

class CalcTestCase(SimpleTestCase):
    #test the calculation
    def test_add(self):      
        result = calc.add(3, 4)
        self.assertEqual(result, 7)
    def test_add_2(self):
        result = calc.subtract(10, 5)
        self.assertEqual(result, 5)