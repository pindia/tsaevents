# Django imports
from django.http import HttpResponse, Http404, HttpResponseRedirect
from django.shortcuts import render_to_response, get_object_or_404
from django.db.models import Q
from django.db import transaction
from django.contrib.auth import login, authenticate, logout
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib.auth.forms import AuthenticationForm
from django.db import connection
from django import forms
from django.core.mail import send_mail
from django.utils.html import escape

# Mako imports
from mako.template import Template
from mako import exceptions
from mako.lookup import TemplateLookup

# Standard library imports
import time, datetime, os, timeit, string, random
from itertools import *

# Project-specific imports
from models import *
from tsa.config import *
import tsa.settings
from rest import reSTify

# Define decorators

chapter_admin_required = user_passes_test(lambda u: u.is_authenticated() and u.profile.is_admin)
system_admin_required = user_passes_test(lambda u: u.is_authenticated() and u.is_superuser)


def get_template(name):
    mylookup = TemplateLookup(directories=[TEMPLATE_DIR])
    return mylookup.get_template(name)

def render_template(name,request,**kwds):
    if 'ENABLE_ADMIN' in request.GET and request.user.is_superuser:
        request.session['DISABLE_ADMIN'] = False
    '''if 'ENABLE_ADMIN' in request.GET and request.session.get('ADMIN_ID'):
        user = User.objects.get(id=int(request.session.get('ADMIN_ID')))
        user.backend = 'django.contrib.auth.backends.ModelBackend'
        login(request, user)
        return HttpResponseRedirect('/')'''
    if 'DISABLE_ADMIN' in request.GET or request.session.get('DISABLE_ADMIN'):
        request.user.is_superuser = False
        request.user.admin_disabled = True
        request.session['DISABLE_ADMIN'] = True
    try:
        if request.user.is_authenticated():
            kwds.update(dict(
                user=request.user,
                chapter=request.user.profile.chapter,
                messages=request.user.get_and_delete_messages(),
            ))
        kwds.update(dict(
            MODE = tsa.settings.MODE,
            DEPLOYED = DEPLOYED,
            connection = connection,
            cycle = cycle(['odd','even'])
        ))
        t = get_template(name)
        txt = t.render(**kwds)
    except:
        return HttpResponse(exceptions.html_error_template().render() )
    return HttpResponse(txt)
    
def message(request, msg):
    request.user.message_set.create(message=msg)

def log(request, type, text, affected=None, c=None):
    SystemLog(chapter=(c or request.chapter), user=request.user, type=type, text=text, affected=affected).save()

def notify(request, target, type, text):
    SystemLog(chapter=request.chapter, user=request.user, type=type, text=text, affected=target, is_personal=True).save()

def notify_all(request, targets, type, text):
    for target in targets:
        notify(request, target, type, text)


def name(user):
    return '%s %s' % (user.first_name, user.last_name)

def login_url(user):
    return '/quick_login?user=%s&auth=%s' % (user.id, user.password.split('$')[2])
    
def generate_password():
    c, v = 'bcdfghjklmnpqrstvwxz', 'aeiou'
    r = random.choice
    return r(c) + r(v) + r(c) + r(v) + r(c) + str(random.randint(100,999))
    



@login_required
def index(request):
    if not request.chapter:
        return HttpResponseRedirect('/config/chapter_list')
    return render_template('index.mako',request, events=Event.objects.all())


def help_viewer(request, page='index'):
    try:
        f = open(paths(DOCS_DIR, '%s.rst' % page))
    except IOError:
        return render_template('helpviewer.mako', request, body='Error: page "%s" not found' % page)
    html = reSTify(f.read())
    return render_template('helpviewer.mako',request,body=html)

def login_view(request):
    class LoginForm(forms.Form):
            username = forms.CharField()
            password = forms.CharField(widget=forms.PasswordInput)
    if request.method == 'POST':
        form = LoginForm(request.POST)
        if form.is_valid():
            d = form.cleaned_data
            user = authenticate(username=d['username'], password=d['password'])
            if user is not None and user.is_active:
                login(request, user)
                return HttpResponseRedirect('/')
        # Reinitialize the form to be empty; don't want to retransmit password in HTML source
        return render_template('registration/login.mako', request, form=LoginForm(), error=True) 
    else:
        form = LoginForm()
        return render_template('registration/login.mako', request, form=form)

def logout_view(request):
    logout(request)
    return HttpResponseRedirect('/accounts/login')


def quick_login(request):
    user = User.objects.get(id=int(request.GET['user']))
    if user.is_superuser and DEPLOYED:  
        return HttpResponse('Error: Admins cannot login using the quick links for security reasons.')
    if user.password.split('$')[2] == request.GET['auth']:
        user.backend = 'django.contrib.auth.backends.ModelBackend'
        login(request, user)
        return HttpResponseRedirect(request.GET.get('next','/'))
    else:
        return HttpResponse('Error: Authentication token is invalid. Either you\'re trying to login as someone else using your authentication token (nice try), or your password has been reset since this link was generated.')

@login_required
def update_indi(request):
    if request.method == 'POST':
        eid = int(request.POST['add_indi_event'])
        if eid != -1:
            e = Event.objects.get(id=eid)
            if e.is_locked(request.user):
                message(request, 'Error: Event is locked')
            elif request.user in e.entrants.all():
                message(request, 'Error: You are already in that event.') 
            else:
                e.entrants.add(request.user)
                message(request, 'Individual event "%s" added.' % e.name)
                log(request, 'event_add', '%s added the individual event %s.' % (name(request.user), e.name))
    if 'delete_event' in request.GET:
        eid = int(request.GET['delete_event'])  
        e = Event.objects.get(id=eid)
        e.entrants.remove(request.user)
        message(request, 'Individual event "%s" removed.' % e.name)
        log(request, 'event_remove', '%s removed the individual event %s.' % (name(request.user), e.name))
    return index(request)


    
    

@login_required 
def settings(request):
    fields = Field.objects.filter(chapter=request.chapter, view_perm=1)
    if request.method == 'POST':
        if request.POST['action'] == 'Regenerate Password':
            password = generate_password()
            u = request.user
            u.set_password(password)
            u.save()
            url = login_url(u)
            body = get_template('email/reset_password.mako').render(name=u.first_name, username=u.username, password=password, login_url=url)
            send_mail('TSA Event Registration Login', body, 'State High TSA <scahs-tsa@pindi.us>', [u.email])
            message(request, 'Your password has been reset. Check your email for your new information.')
        else:
            p = request.user.profile
            print request.POST
            if 'posts_email' in request.POST:
                p.posts_email = 2
            else:
                p.posts_email = 0
            p.save()
            u = request.user
            u.first_name = escape(request.POST['first_name'])
            u.last_name = escape(request.POST['last_name'])
            u.email = request.POST['email']
            if request.POST['new_password'] and not u.check_password(request.POST['old_password']):
                message(request, 'Error: Old password is not correct.')
            elif request.POST['new_password'] != request.POST['confirm_password']:
                message(request, 'Error: Password do not match.')
            elif request.POST['new_password']:
                u.set_password(request.POST['new_password'])
                message(request, 'Your password has been changed.')
                log(request, 'password_change', '%s changed their password.' % (name(request.user)))
            u.save()
            message(request, 'Your settings have been updated.')
    return render_template('settings.mako',request, url=login_url(request.user), fields=fields)

def create_account(request):
    
    class NewUserForm(forms.Form):
            username = forms.CharField()
            password = forms.CharField(widget=forms.PasswordInput)
            first_name = forms.CharField()
            last_name = forms.CharField()
            email = forms.EmailField()
            chapter = forms.ChoiceField(choices=[(c.id, c.name) for c in Chapter.objects.all()])
            
    if request.method == 'POST':
        form = NewUserForm(request.POST)
        if form.is_valid():
            d = form.cleaned_data
    
    
            #if domain != 'scasd.org':
            #    return HttpResponse('Error: Email must be @scasd.org')
            username = d['username']
            password = d['password']
            email = d['email']
            first_name = escape(d['first_name'])
            last_name = escape(d['last_name'])
            chapter = Chapter.objects.get(id=int(d['chapter']))
            #password = generate_password()
        
            u = User(username=username, first_name=first_name, last_name=last_name, email=email)
            u.set_password(password)
            u.save()
            profile = UserProfile(is_member=True, chapter=chapter, user=u)
            profile.save()
        
            #url = login_url(u)
            
            #t = get_template('email/newuser.mako')
            #body = t.render(name=first_name, username=username, password=password, login_url=url, chapter=chapter.name)
          
            #send_mail('TSA Event Registration Login', body, 'State High TSA <scahs-tsa@pindi.us>', [email])
                
            SystemLog(chapter=chapter, user=u, affected=u, type='new_user', text='New user %s registered.' % name(u)).save()
                
            u = authenticate(username=username, password=password)
            login(request, u)
                
            message(request, 'Your new account has been created.')
            #return HttpResponse('Your account has been created. Check your email for login details.')
            return HttpResponseRedirect('/')
            
    else:
        form = NewUserForm()
        
    return render_template('registration/register.mako', request, form=form)
    
execfile(paths(APP_DIR, 'views_lists.py'))
execfile(paths(APP_DIR, 'views_team.py'))
execfile(paths(APP_DIR, 'views_admin.py'))
