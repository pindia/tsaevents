<%inherit file='../base.mako' />

<%def name='title()'>Edit Chapter</%def>
<%
def sel(cond):
    return 'selected="yes"' if cond else ''

%>

<h2>Chapter Information</h2>

<table class="aligner">
    <tr><th>Name:</th><td>${chapter.name}</td></tr>
    % if chapter.link:
        <tr><td><i>Master:</i></td><td><i>${chapter.link.name}</i></td>
    % endif
    <tr><th>Members:</th><td>${chapter.members.filter(is_member=True).count()}</td></tr>
    <tr><th>Teams:</th><td>${chapter.teams.count()}</td></tr>
</table>

<form method="post" action="/edit_chapter">

<h2>Chapter Settings</h2>

<p>See the <a href="/help/advisor_guide#chapter-settings">advisor guide</a> for details about chapter settings.</p>



    <div class="form-horizontal well well-condensed">

        <fieldset>

            <div class="control-group">
                <label class="control-label" for="mode">Mode</label>
                <div class="controls">
                    <select name="mode" id="mode" class="input-medium">
                        <option value="region" ${'selected' if chapter.mode == 'region' else ''}>Region</option>
                        <option value="state" ${'selected' if chapter.mode == 'state' else ''}>State</option>
                        <option value="nation" ${'selected' if chapter.mode == 'nation' else ''}>Nation</option>
                    </select>
                    <p class="help-block">Conference to calculate qualification information for</p>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="chapter_id">Chapter ID</label>
                <div class="controls">
                    <input type="entry" id="chapter_id" name="chapter_id" value=${chapter.chapter_id}>
                    <p class="help-block">Prefix for all IDs; like <b>2045</b>-xxxx</p>
                </div>

            </div>
            <div class="control-group">
                <label class="control-label" for="chapter_id">Allow new users</label>
                <div class="controls">
                    <input type="checkbox" name="register_open" ${'checked="yes"' if chapter.register_open else ''}>
                </div>

            </div>
            <div class="control-group">
                <label class="control-label" for="key">Key</label>
                <div class="controls">
                    <input type="entry" name="key" id="key" value=${chapter.key}>
                    <p class="help-block">Optional; new users must enter this key to register</p>
                </div>

            </div>
            <div class="control-group">
                <label class="control-label" for="info">Info</label>
                <div class="controls">
                    <textarea name="info" id="info" style="width:300px; height:100px;">${chapter.info}</textarea>
                    <p class="help-block">Displayed to new users on registration screen</p>
                </div>
            </div>
        </fieldset>
    </div>



% if chapter.link:
    <p>Switch to master chapter to view and edit fields.</p>
% else:

<h2>Fields</h2>

<p>See the <a href="/help/advisor_guide#fields">advisor guide</a> for details about fields.</p>


<table align="center" class="table table-striped table-condensed">
    <tr>
        <th>Name</th>
        <th>Short Name</th>
        <th>Category</th>
        <th>Weight</th>
        <th>Who may view?</th>
        <th>Who may edit?</th>
        <th>Type</th>
        <th>Default</th>
    </tr>
    % for field in chapter.get_fields():
    <tr>
        <td><input type="entry" size="input-medium" name="${field.id}_name" value="${field.name}"></td>
        <td><input type="entry" class="input-small" name="${field.id}_short_name" value="${field.short_name}"></td>
        <td><input type="entry" class="input-small" name="${field.id}_category" value="${field.category}"></td>
        <td><input type="entry" class="input-mini" name="${field.id}_weight" value="${field.weight}"></td>
        
        <td>
            <select name="${field.id}_view_perm" class="input-small">
                <option value="0" ${sel(field.view_perm == 0)}>Admin only</option>
                <option value="1" ${sel(field.view_perm == 1)}>User or admin</option>
            </select>
        </td>
        <td>
            <select name="${field.id}_edit_perm" class="input-small">
                <option value="3" ${sel(field.edit_perm == 3)}>Nobody</option>
                <option value="2" ${sel(field.edit_perm == 2)}>Admin only (logged)</option>
                <option value="0" ${sel(field.edit_perm == 0)}>Admin only</option>
                <option value="1" ${sel(field.edit_perm == 1)}>User or admin</option>
            </select>
        </td>
        
        <td>${field.get_type_display()}</td>
        <td>${field.format_value(field.default_value)}</td>
    </tr>
    % endfor
</table>

<h3>New Field</h3>
    <table class="layouttable aligner">
        <tr><td>Name:</td><td><input type="entry" name="name"></td></tr>
        <tr><td>Short Name:</td><td><input type="entry" name="short_name"></td></tr>
        <tr><td>Type:</td><td>
        <select name="type">
            <option value="text">Text</option>
            <option value="boolean">Boolean (Yes/No)</option>
        </select></td></tr>
        <tr><td>Default:</td><td><input type="entry" name="default"></td>
    </table>
% endif
<input type="submit" value="Submit" class="btn btn-primary">


</form>