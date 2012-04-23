<%inherit file='base.mako' />

<%def name='title()'>Home</%def> <%%>

<div class="row">

    <div id="your_events" class="span6">

      % if user.profile.is_member:

        % if user.profile.indi_id and MODE != 'nation':
        <p>
          Your individual ID is: ${chapter.chapter_id}-${user.profile.get_id()}
        </p>
        % endif

        <%include file="components/your_events.mako" />

      % else:

        <!--You cannot sign up for events because you are a chapter advisor.-->
        <%include file="components/chapter_summary.mako" />

      % endif

    </div>

    <div id="chapter_info" class="span4">

      <%include file="components/announcements.mako" />
      <%include file="components/files.mako" />
      <%include file="components/calendar.mako" />

    </div>

</div>
