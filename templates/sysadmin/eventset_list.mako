<%inherit file='../base.mako' />

<%def name='title()'>Event Set List</%def>

<table class="tabular_list" align="center">
    <tr>
        <th>Region</th><th>State</th><th>Level</th><th>View</th>
    </tr>
    % for s in evsets:
    <tr>
        <td>${s.region}</td>
        <td>${s.state}</td>
        <td>${s.level}</td>
        <td><a href="/config/eventsets/${s.id}">View</a></td>
    </tr>
    % endfor
</table>

<h2>New Event Set</h2>
<form method="POST">
Copy from:
<select name="copy_id">
    % for s in evsets:
        <option value="${s.id}">${s}</option>
    % endfor
</select><br>
Region: <input type="entry" name="new_region"><br>
<input type="submit" value="Create">
</form>