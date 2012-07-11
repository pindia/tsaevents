<%inherit file='../base.mako' />

<%def name='title()'>Edit ${level} Events</%def>


<%def name='events_table(events)'>
<table class="table table-bordered table-striped" align="center">
    <tr>
        <th>Name</th>
        <th>Short name</th>
        <th>Min #</th>
        <th>Max #</th>
    </tr>
    % for e in events:
    <tr>
        <td><input type="entry" name="${e.id}_name" value="${e.name}" size="40"></td>
        <td><input type="entry" name="${e.id}_short_name" value="${e.short_name}"></td>
        <td><input type="entry" name="${e.id}_min_team_size" value="${e.min_team_size}" size="2"></td>
        <td><input type="entry" name="${e.id}_team_size" value="${e.team_size}" size="2"></td>
    </tr>
    % endfor
</table>
</%def>

<p> <a href="/config/events/HS/">High School</a> &bull; <a href="/config/events/MS/">Middle School</a></p>

<p>Note: Editing event information on this page affects every single event in the system! I hope you know what you're doing.</p>

<form method="POST">
    
<h2>National Events</h2>

${events_table(national_events)}

% for state, events in states.items():

<h2>${state} Events</h2>

${events_table(events)}

% endfor

<p>
    Add event:
    <input type="text" placeholder="Event name" name="add-event-name">
    of type
    <select name="add-event-type">
        <option value=''>--- Select ---</option>
        <option value="National">National</option>
        % for state in states:
            <option value="${state}">${state}</option>
        % endfor
    </select>
</p>

<input type="submit" value="Save">
</form>