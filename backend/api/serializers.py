from rest_framework import serializers
from .models import (
    Users,
    CustomerProfile,
    CustomerActivity,
    CustomerChurnLabel,
    CustomerTimeSeriesSummary,
    AuditLogs
)


# -----------------------
#  USERS (Admin → User List)
# -----------------------
class AdminUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = Users
        fields = ["user_id", "username", "role", "created_at"]


# -----------------------
#  CUSTOMER PROFILE (Admin → User Detail)
# -----------------------
class AdminCustomerProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomerProfile
        fields = "__all__"


# -----------------------
#  CUSTOMER ACTIVITY
# -----------------------
class CustomerActivitySerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomerActivity
        fields = "__all__"


# -----------------------
#  CUSTOMER TIME SERIES SUMMARY
# -----------------------
class CustomerTimeSeriesSummarySerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomerTimeSeriesSummary
        fields = "__all__"


# -----------------------
#  AUDIT LOGS
# -----------------------
class AdminLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuditLogs
        fields = "__all__"
