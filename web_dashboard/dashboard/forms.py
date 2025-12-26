from django import forms
from .models import Customer

class CustomerForm(forms.ModelForm):
    class Meta:
        model = Customer
        fields = [
            "age",
            "province",
            "tenure",
            "gender",
            "work_sector",
        ]

        widgets = {
            "age": forms.NumberInput(attrs={"class": "form-control"}),
            "province": forms.TextInput(attrs={"class": "form-control"}),
            "tenure": forms.NumberInput(attrs={"class": "form-control"}),
            "gender": forms.Select(
                choices=[("Male", "Male"), ("Female", "Female")],
                attrs={"class": "form-select"}
            ),
            "work_sector": forms.TextInput(attrs={"class": "form-control"}),
        }
