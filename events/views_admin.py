@chapter_admin_required
def system_log(request):
    return render_template('system_log.mako', request, logs=SystemLog.objects.order_by('-date'))
    
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
    
