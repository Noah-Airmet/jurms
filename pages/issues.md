---
layout: default
title: Issues
permalink: /issues/
---

<div class="container">
  {% assign now_epoch = 'now' | date: '%s' %}
  {% assign upcoming_by_deadline = site.issues | where: "upcoming", true | sort: "deadline" %}
  {% assign next_call_issue = nil %}
  {% for issue in upcoming_by_deadline %}
    {% if issue.deadline %}
      {% assign issue_epoch = issue.deadline | date: "%s" %}
      {% if issue_epoch >= now_epoch %}
        {% assign next_call_issue = issue %}
        {% break %}
      {% endif %}
    {% endif %}
  {% endfor %}

  <a href="{{ '/call-for-papers/' | relative_url }}" class="cfp-banner">
    <span class="cfp-banner__eyebrow">Call for Papers</span>
    {% if next_call_issue %}
      <span class="cfp-banner__text">
        {{ next_call_issue.title }}{% if next_call_issue.theme %} — {{ next_call_issue.theme }}{% endif %}
        {% if next_call_issue.deadline %} · Submissions due {{ next_call_issue.deadline | date: "%B %-d, %Y" }}{% endif %}
      </span>
    {% else %}
      <span class="cfp-banner__text">View the next upcoming issue and submission details</span>
    {% endif %}
  </a>

  <div class="page-header">
    <h1 class="page-header__title">Issues</h1>
    <p class="page-header__lead">Browse all published issues of Telos.</p>
  </div>

  {% assign all_issues = site.issues | sort: 'publication_date' | reverse %}

  {% if all_issues.size > 0 %}
    <div class="issues-grid">
      {% for issue in all_issues %}
        <a href="{{ issue.url | relative_url }}" class="issue-thumb{% if issue.upcoming %} issue-thumb--upcoming{% endif %}">
          {% assign pub_date = issue.publication_date | default: issue.date %}
          <p class="issue-thumb__meta">
            {% if issue.upcoming %}<span class="issue-thumb__badge">Upcoming</span>&ensp;&middot;&ensp;{% endif %}
            Vol.&thinsp;{{ issue.volume }}, No.&thinsp;{{ issue.number }}
            &ensp;&middot;&ensp;
            {{ pub_date | date: "%B %Y" }}
          </p>
          <p class="issue-thumb__title">{{ issue.title }}</p>
          {% if issue.theme %}
            <p class="issue-thumb__theme">&ldquo;{{ issue.theme }}&rdquo;</p>
          {% endif %}
          {% assign issue_articles = site.articles | where: "issue", issue.issue_id %}
          <p class="issue-thumb__count">
            {% if issue.upcoming %}
              {% if issue.deadline %}
                Papers due {{ issue.deadline | date: "%B %-d, %Y" }}
              {% else %}
                Coming {{ pub_date | date: "%B %Y" }}
              {% endif %}
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
