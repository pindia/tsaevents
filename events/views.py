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
from django.core.mail import send_mail, send_mass_mail, mail_admins, EmailMessage, get_connection
from django.utils.html import escape
from django.contrib import messages

# Mako imports
from mako.template import Template
from mako import exceptions
from mako.lookup import TemplateLookup

# Standard library imports
import time, datetime, os, timeit, string, random, hashlib, vobject
from itertools import *
from smtplib import SMTPException

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
                chapter=request.chapter,
                messages=messages.get_messages(request),
                MODE = request.chapter.mode,
            ))
        kwds.update(dict(
            DEPLOYED = DEPLOYED,
            connection = connection,
            cycle = cycle(['odd','even'])
        ))
        t = get_template(name)
        txt = t.render(**kwds)
    except:
        return HttpResponse(exceptions.html_error_template().render())
    return HttpResponse(txt, mimetype=kwds.get('mimetype','text/html'))
    
def message(request, msg):
    messages.info(request, msg)
#    request.user.message_set.create(message=msg)

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
    
def get_token(user):
    return user.password.split('$')[2]
    
def verify_token(user, token):
    return user.password.split('$')[2] == token
    
def generate_password():
    c, v = 'bcdfghjklmnpqrstvwxz', 'aeiou'
    r = random.choice
    return r(c) + r(v) + r(c) + r(v) + r(c) + str(random.randint(100,999))
    


def custom404(request):
    print request.user
    return render_template('errors/404.mako', request, parent='../base.mako' if request.user.is_authenticated() else '../layout.mako')

def custom500(request):
    return render_template('errors/500.mako', request, parent='../base.mako' if request.user.is_authenticated() else '../layout.mako')

@login_required
def index(request):
    if not request.chapter:
        return HttpResponseRedirect('/config/chapter_list')
    return render_template('index.mako',request, events=Event.objects.all())
    
@login_required
def xml(request):
    return render_template('xml.mako', request, mimetype='text/xml')
    

    
def calendar(request):
    if 'chapter' not in request.GET:
        return HttpResponse('No chapter specified.')
    chapter = Chapter.objects.get(id=int(request.GET['chapter']))
    if 'key' not in request.GET or chapter.calendar_key != request.GET['key']:
        return HttpResponse('Invalid key specified.')
    cal = vobject.iCalendar()
    cal.add('method').value = 'PUBLISH'  # IE/Outlook needs this
    for event in (chapter.link or chapter).calendar_events.filter(date__gte=datetime.date.today()):
        vevent = cal.add('vevent')
        vevent.add('summary').value = event.name
        vevent.add('dtstart').value = event.date
    icalstream = cal.serialize()
    response = HttpResponse(icalstream)#, mimetype='text/calendar')
    response['Filename'] = 'calendar.ics'  # IE needs this
    response['Content-Disposition'] = 'attachment; filename=calendar.ics'
    return response



def help_viewer(request, page='index'):
    try:
        f = open(paths(DOCS_DIR, '%s.rst' % page))
    except IOError:
        return render_template('helpviewer.mako', request, body='Error: page "%s" not found' % page)
    html = reSTify(f.read())
    return render_template('helpviewer.mako',request,body=html)
    
@login_required    
def contact(request):
    return render_template('contact.mako', request)

def login_view(request):
    class LoginForm(forms.Form):
            username = forms.CharField()
            password = forms.CharField(widget=forms.PasswordInput)
            stay_signed_in = forms.BooleanField(required=False)
    if request.method == 'POST':
        form = LoginForm(request.POST)
        if form.is_valid():
            d = form.cleaned_data
            if not d['stay_signed_in']:
                request.session.set_expiry(0)
            user = authenticate(username=d['username'], password=d['password'])
            if user is not None and user.is_active:
                login(request, user)
                return HttpResponseRedirect(request.POST['next'])
        # Reinitialize the form to be empty; don't want to retransmit password in HTML source
        return render_template('registration/login.mako', request, form=LoginForm(), chapters=Chapter.objects.all(), next=request.POST['next'], error_msg="Sorry, that's not a valid username or password.") 
    else:
        form = LoginForm()
        if 'next' in request.GET and request.user.is_authenticated():
            error_msg = 'You must be logged in as an administrator to view that page.'
        elif 'next' in request.GET and request.GET['next'] != '/':
            error_msg = 'You must be logged in to view that page.'
        else:
            error_msg = ''
        return render_template(
            'registration/login.mako', request, form=form,
            next=request.GET.get('next', '/'), chapters=Chapter.objects.all(), error_msg=error_msg)


def logout_view(request):
    logout(request)
    return HttpResponseRedirect('/accounts/login')


def quick_login(request):
    try:
        user = User.objects.get(id=int(request.GET['user']))
    except (ValueError, User.DoesNotExist):
        return HttpResponse('Error: Invalid user specified. Perhaps your account has been deleted?')
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
    viewable_fields = request.chapter.get_fields().filter(view_perm=Field.USER_OR_ADMIN)
    category_names = set(viewable_fields.values_list('category', flat=True))
    categories = {}
    for cname in category_names:
        fields = viewable_fields.filter(category=cname)
        if fields:
            categories[cname] = fields
    
    if request.method == 'POST':
        # Update fields
        if request.user.profile.is_member:
            editable_fields = viewable_fields.filter(edit_perm=Field.USER_OR_ADMIN)
            for field in editable_fields:
                if field.type == Field.BOOLEAN:
                    request.user.profile.set_field(field, ('field_%d' % field.id) in request.POST)
                else:
                    request.user.profile.set_field(field, request.POST['field_%d' % field.id])
        # Update email settings
        p = request.user.profile
        if 'posts_email' in request.POST:
            p.posts_email = 2
        else:
            p.posts_email = 0
        p.save()
        # Update user information (name + email)
        u = request.user
        u.first_name = escape(request.POST['first_name'])
        u.last_name = escape(request.POST['last_name'])
        u.email = request.POST['email']
        # Update user passwod
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
    return render_template('settings.mako',request, url=login_url(request.user), categories=categories)

def reset_password(request):
    if request.method == 'POST':
        if 'username' in request.POST:
            try:
                user = User.objects.get(Q(username=request.POST['username']) | Q(email=request.POST['username']))
            except User.DoesNotExist:
                return render_template('registration/request_reset.mako', request, error_msg='Unknown username or email address')
            t = get_template('email/reset_password.mako')
            body = t.render(name=user.first_name, chapter=user.profile.chapter.name, uid=user.id, token=get_token(user))
            try:
                send_mail('TSAEvents Password Reset', body, '%s TSA <system@tsaevents.com>' % user.profile.chapter.name, [user.email], fail_silently=False)
            except SMTPException:
                return render_template('registration/request_reset.mako', request, error_msg='Unable to send email. Contact server administrator.')
            return render_template('registration/request_reset.mako', request, success_msg='Further instructions have been sent to your email address.')
        if 'password' in request.POST:
            uid = int(request.POST['user'])
            auth = request.POST.get('auth','')
            user = User.objects.get(id=uid)
            if not verify_token(user, auth):
                return render_template('registration/request_reset.mako', request, error_msg='Invalid authentication token. Try re-sending the email.')
            password = request.POST['password']
            confirm_password = request.POST['confirm_password']
            if password != confirm_password:
                return render_template('registration/perform_reset.mako', request, uid=uid, auth=auth , error_msg='Error: passwords do not match.')
            user.set_password(password)
            user.save()
            user = authenticate(username=user.username, password=password)
            login(request, user)
            message(request, 'New password set. You have been automatically logged in.')
            return HttpResponseRedirect('/')
    elif 'user' in request.GET:
        uid = int(request.GET['user'])
        auth = request.GET.get('auth','')
        user = User.objects.get(id=uid)
        if verify_token(user, auth):
            return render_template('registration/perform_reset.mako', request, uid=uid, auth=auth )
        else:
            return render_template('registration/request_reset.mako', request, error_msg='Invalid authentication token. Try re-sending the email.')
    
    return render_template('registration/request_reset.mako', request)

def request_chapter(request):
    class RequestForm(forms.Form):
            chapter_name = forms.CharField()
            region = forms.CharField()
            level = forms.ChoiceField(choices=(('HS','High School'),('MS','Middle School')) )
            admin_username = forms.CharField()
            admin_first_name = forms.CharField()
            admin_last_name = forms.CharField()
            admin_email = forms.EmailField()    
            admin_password = forms.CharField(widget=forms.PasswordInput)
            confirm_password = forms.CharField(widget=forms.PasswordInput)
            comments = forms.CharField(widget=forms.Textarea, required=False) 
            
    if request.method == 'POST':
        form = RequestForm(request.POST)
        if form.is_valid():
            d = form.cleaned_data
            if d['admin_password'] != d['confirm_password']:
                return render_template('registration/request_chapter.mako', request, form=form, error_msg = 'Passwords do not match.')
            if User.objects.filter(username=d['admin_username']).count() != 0:
                return render_template('registration/request_chapter.mako', request, form=form, error_msg = 'Username is already in use.')
            t = get_template('email/request_chapter.mako')
            body = t.render(**d)
            send_mail('TSAEvents Chapter Request', body, 'TSAEvents <system@tsaevents.com>', ['pindi.albert@gmail.com'], fail_silently=False)
            return HttpResponse('Your request has been processed and is awaiting approval. You will be emailed when your new chapter is created.')
            
    else:
        form = RequestForm()
        
    return render_template('registration/request_chapter.mako', request, form=form)
    
    



def create_account(request):
    
    if 'chapter' not in request.REQUEST or request.REQUEST['chapter'] == '-1':
        return HttpResponseRedirect('/accounts/login')
    chapter = Chapter.objects.get(id=int(request.REQUEST['chapter']))
    fields = chapter.get_fields().filter(edit_perm=Field.USER_OR_ADMIN)

    class NewUserForm(forms.Form):
            if chapter.key:
                key = forms.CharField()
            username = forms.CharField()
            password = forms.CharField(widget=forms.PasswordInput)
            confirm_password = forms.CharField(widget=forms.PasswordInput)
            first_name = forms.CharField()
            last_name = forms.CharField()
            email = forms.EmailField()
    
    
    
            
    if request.method == 'POST':
        form = NewUserForm(request.POST)
        
        def show_error(msg):
            return render_template('registration/register.mako', request, form=form, chapter=chapter, fields=fields, error_msg=msg)
            
        if form.is_valid():
            d = form.cleaned_data
    
    
            #if domain != 'scasd.org':
            #    return HttpResponse('Error: Email must be @scasd.org')
            if 'key' in d:
                key = d['key']
                if key != chapter.key:
                    return show_error('Invalid key. Contact your chapter advisor for assistance.')
            username = d['username']
            if User.objects.filter(username=username).count() != 0:
                return show_error('Username is already in use.')
            password = d['password']
            confirm_password = d['confirm_password']
            if password != confirm_password:
                return show_error('Passwords do not match.')
            email = d['email']
            first_name = escape(d['first_name'])
            last_name = escape(d['last_name'])
            #password = generate_password()
        
            u = User(username=username, first_name=first_name, last_name=last_name, email=email)
            u.set_password(password)
            u.save()
            profile = UserProfile(is_member=True, chapter=chapter, user=u)
            profile.save()
            
            for field in fields:
                if field.type == Field.BOOLEAN:
                    profile.set_field(field, ('field_%d' % field.id) in request.POST)
                else:
                    profile.set_field(field, request.POST.get('field_%d' % field.id, field.default_value))
        
                
            SystemLog(chapter=chapter, user=u, affected=u, type='new_user', text='New user %s registered.' % name(u)).save()
                
            u = authenticate(username=username, password=password)
            login(request, u)
                
            message(request, 'Your new account has been created.')
            return HttpResponseRedirect('/')
            
    else:
        form = NewUserForm()
    
    
        
    return render_template('registration/register.mako', request, form=form, chapter=chapter, fields=fields)
    
execfile(paths(APP_DIR, 'views_lists.py'))
execfile(paths(APP_DIR, 'views_team.py'))
execfile(paths(APP_DIR, 'views_admin.py'))
