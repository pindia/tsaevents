<%inherit file='../base.mako' />

<%def name='title()'>Edit Event Set</%def>
<%def name='scripts()'>
<script language="javascript">

$(document).ready(function() {
   $('.region_edit,.state_edit,.nation_edit').hide()
 });
 
</script>
</%def>


<h3>Editing ${es}</h3>

<p>Note: Editing a national qualification number will update all event sets in the level. Editing a state qualification number will update all event sets in the state.<br>
Click a column heading to enable editing.</p>


<form method="POST">
<table class="tabular_list" align="center">
    <tr>
        <th>Event</th>
        <th><a href="javascript:void(0)" onclick="$('.region_edit').show();$('.region_num').hide()">Max Region</a></th>
        <th><a href="javascript:void(0)" onclick="$('.state_edit').show();$('.state_num').hide()">Max State</a></th>
        <th><a href="javascript:void(0)" onclick="$('.nation_edit').show();$('.nation_num').hide()">Max Nation</a></th>
    </tr>
    % for e in es.events.all():
    <tr>
        <td>${e.name}</td>
        <td>
            <span class="region_num">${e.render_region()}</span>
            <input type="entry" name="${e.id}_region" class="region_edit" value="${e.max_region}" size="2">
        </td>
        <td>
            <span class="state_num">${e.render_state()}</span>
            <input type="entry" name="${e.id}_state" class="state_edit" value="${e.max_state}" size="2">
        </td>
        <td>
            <span class="nation_num">${e.render_nation()}</span>
            <input type="entry" name="${e.id}_nation" class="nation_edit" value="${e.max_nation}" size="2">
        </td>
    </tr>
    % endfor
</table>
<input type="submit" value="Save">
</form>