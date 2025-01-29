"""
Test custom django management commands.
"""

from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


class CommandTests(SimpleTestCase):
    """Test commands."""

    @patch('django.core.management.base.BaseCommand.check')
    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for database ready."""
        patched_check.return_value = True
        call_command('wait_for_db')
        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    @patch('django.core.management.base.BaseCommand.check')
    def test_wait_for_db_delay(self, patched_check, patched_sleep):
        """Test waiting for database when getting operational error."""
        # Simulate database errors followed by success
        patched_check.side_effect = [Psycopg2Error] * 2 + \
            [OperationalError] * 3 + [True]
        call_command('wait_for_db')
        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=['default'])
