
@chapter_admin_required
def member_fields(request, category):
    category = category or 'Main'
    members = User.objects.filter(profile__chapter=request.chapter, is_superuser=False, profile__is_member=True).order_by('last_name')
    fields = request.chapter.get_fields()
    categories = set(fields.values_list('category', flat=True))
    fields = fields.filter(category=category)
    if request.method == 'POST':
        i = 0
        for member in members:
            for field in fields:
                key = '%d_%d' % (member.id, field.id)
                fv = member.profile.get_field(field)
                if field.type == 0:
                    if fv and key not in request.POST:
                        member.profile.set_field(field, False)
                        i += 1
                    if not fv and key in request.POST:
                        member.profile.set_field(field, True)
                        i += 1
                else:
                    if fv != request.POST[key]:
                        member.profile.set_field(field, request.POST[key])
                        i += 1
        message(request, '%d fields updated.' % i)
                        
                    
    return render_template('chapadmin/member_fields.mako', request, members=members, fields=fields, categories=categories, category=category)


@chapter_admin_required
def edit_chapter(request):
    c = request.chapter
    if request.method == 'POST':
        c.register_open = 'register_open' in request.POST
        c.message = request.POST['message']
        c.info = request.POST['info']
        c.key = request.POST['key']
        c.chapter_id=request.POST['chapter_id']
        c.save()
        message(request, 'Chapter settings updated.')
        if not c.link: # Only edit fields if no master chapter
            for field in c.get_fields():
                name = request.POST['%d_name' % field.id]
                short_name = request.POST['%d_short_name' % field.id]
                category = request.POST['%d_category' % field.id]
                weight = int(request.POST['%d_weight' % field.id])
                view_perm = int(request.POST['%d_view_perm' % field.id])
                edit_perm = int(request.POST['%d_edit_perm' % field.id])
                if name == 'DELETE':
                    field.delete()
                    continue
                if field.name != name or field.category != category or field.weight != weight or field.short_name != short_name or field.view_perm != view_perm or field.edit_perm != edit_perm:
                    field.name = name
                    field.short_name = short_name
                    field.category = category
                    field.weight = weight
                    field.edit_perm = edit_perm
                    field.view_perm = view_perm
                    field.save()
            
            name = request.POST['name']
            if name: # Create new field
                is_boolean = request.POST['type'].lower() == 'boolean'
                default = request.POST['default']
                if is_boolean:
                    if default.lower() in ['1','true','yes']:
                        default = '1'
                    elif default.lower() in ['0','false','no']:
                        default = '0'
                    else:
                        message(request, "Error: unrecognized default value, please enter 'yes' or 'no'.")
                        return render_template('chapadmin/edit_chapter.mako', request, chapter=c)
                else:
                    default = request.POST['default']
                f = Field()
                f.short_name = request.POST['short_name']
                f.name = name
                f.type = 0 if is_boolean else 1
                f.chapter = c
                f.default_value = default
                f.save()
            

            
        
    return render_template('chapadmin/edit_chapter.mako', request, chapter=c)




@login_required
def system_log(request):
    t = request.GET.get('type', 'chapter')
    if request.user.is_superuser and t == 'system':
        logs = SystemLog.objects.filter(chapter=None)
    elif request.user.is_superuser and t == 'all':
        logs = SystemLog.objects.all()
    elif request.user.profile.is_admin and t == 'chapter':
        logs = SystemLog.objects.filter(chapter=request.chapter)
    elif t == 'actions':
        logs = SystemLog.objects.filter(user=request.user)
    else:
        logs = SystemLog.objects.filter(affected=request.user)
    return render_template('system_log.mako', request, logs=logs.order_by('-date'))
    
@system_admin_required
def chapter_list(request):
    if 'switch_chapter' in request.GET:
        if request.GET['switch_chapter'] == '-1':
            request.user.profile.chapter = None
        else:
            c = Chapter.objects.get(pk=int(request.GET['switch_chapter']))
            request.user.profile.chapter = c
        request.user.profile.is_member = False
        request.user.profile.is_admin = True
        request.user.profile.save()
    return render_template('sysadmin/chapter_list.mako', request, chapters=Chapter.objects.all())
    
from django.db.models import AutoField
def copy_model_instance(obj):
    initial = dict([(f.name, getattr(obj, f.name))
                    for f in obj._meta.fields
                    if not isinstance(f, AutoField) and\
                       not f in obj._meta.parents.values()])
    return obj.__class__(**initial)

    
@system_admin_required
def eventset_list(request):
    if request.method == 'POST':
        es = EventSet.objects.get(id=int(request.POST['copy_id']))
        region = request.POST['new_region']
        ns = EventSet(region=region, state=es.state, level=es.level)
        ns.save()
        for e in es.events.all():
            ne = copy_model_instance(e)
            ne.event_set = ns
            ne.save()
        message(request, 'New event set %s created. %d events copied.' % (str(ns), ns.events.count()))
    return render_template('sysadmin/eventset_list.mako', request, evsets = EventSet.objects.all())
    
@system_admin_required
def edit_eventset(request, esid):
    es = EventSet.objects.get(id=int(esid))
    if request.method == 'POST':
        for e in es.events.all():
            max_region = int(request.POST['%d_region' % e.id])
            max_state = int(request.POST['%d_state' % e.id])
            max_nation = int(request.POST['%d_nation' % e.id])
            if e.max_region != max_region:
                e.max_region = max_region
                e.save()
                message(request, 'Regional qualification for %s updated.' % e.name)
            if e.max_state != max_state:
                qs = Event.objects.filter(name=e.name, event_set__state = es.state, event_set__level = es.level)
                qs.update(max_state=max_state)
                message(request, 'State qualification for %s updated. %d event sets affected.' % (e.name, qs.count()))
            if e.max_nation != max_nation:
                qs = Event.objects.filter(name=e.name, event_set__level = es.level)
                qs.update(max_nation=max_nation)
                message(request, 'National qualification for %s updated. %d event sets affected.' % (e.name, qs.count())) 
            
    return render_template('sysadmin/edit_eventset.mako', request, es = es)
    
