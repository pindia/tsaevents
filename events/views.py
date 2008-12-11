# Django imports
from django.http import HttpResponse, Http404
from django.shortcuts import render_to_response, get_object_or_404
from django.db.models import Q
from django.db import transaction
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required
from django.db import connection

# Mako imports
from mako.template import Template
from mako import exceptions
from mako.lookup import TemplateLookup

# Standard library imports
import time, datetime, os, timeit
from itertools import *

# Project-specific imports
from models import *
from tsa.config import *

def get_template(name):
    mylookup = TemplateLookup(directories=[TEMPLATE_DIR])
    return mylookup.get_template(name)

def render_template(name,**kwds):
    try:
        t = get_template(name)
        txt = t.render(**kwds)
    except:
        return HttpResponse(exceptions.html_error_template().render() )
    return HttpResponse(txt)



@login_required
def index(request):
    return render_template('index.mako',user=request.user,events=Event.objects.all())

@login_required
def update_indi(request):
    return index(request)

@login_required
def event_list(request):
    return render_template('event_list.mako',user=request.user,events=Event.objects.all()) 