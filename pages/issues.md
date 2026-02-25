---
layout: default
title: Issues
permalink: /issues/
---

<div class="container">

  <div class="page-header">
    <h1 class="page-header__title">Issues</h1>
    <p class="page-header__lead">Browse all published issues of Telos.</p>
  </div>

  {% assign all_issues = site.issues | sort: 'date' | reverse %}

  {% if all_issues.size > 0 %}
    <div class="issues-grid">
      {% for issue in all_issues %}
        <a href="{{ issue.url | relative_url }}" class="issue-thumb{% if issue.upcoming %} issue-thumb--upcoming{% endif %}">
          <p class="issue-thumb__meta">
            {% if issue.upcoming %}<span class="issue-thumb__badge">Upcoming</span>&ensp;&middot;&ensp;{% endif %}
            Vol.&thinsp;{{ issue.volume }}, No.&thinsp;{{ issue.number }}
            &ensp;&middot;&ensp;
            {{ issue.date | date: "%B %Y" }}
          </p>
          <p class="issue-thumb__title">{{ issue.title }}</p>
          {% if issue.theme %}
            <p class="issue-thumb__theme">&ldquo;{{ issue.theme }}&rdquo;</p>
          {% endif %}
          {% assign issue_articles = site.articles | where: "issue", issue.issue_id %}
          <p class="issue-thumb__count">
            {% if issue.upcoming %}
              Coming {{ issue.date | date: "%B %Y" }}
            {% else %}
              {{ issue_articles.size }} article{% if issue_articles.size != 1 %}s{% endif %}
            {% endif %}
          </p>
        </a>
      {% endfor %}
    </div>
  {% else %}
    <p style="color: var(--c-text-muted); padding: var(--sp-8) 0; font-style: italic;">
      No issues published yet — check back soon.
    </p>
  {% endif %}

</div>
