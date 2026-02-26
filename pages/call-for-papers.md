---
layout: default
title: Call for Papers
permalink: /call-for-papers/
---

<div class="container container--narrow">
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

  <div class="page-header">
    <h1 class="page-header__title">Call for Papers</h1>
    <p class="page-header__lead">Submission details for the next upcoming issue.</p>
  </div>

  {% if next_call_issue %}
    <section class="cfp-panel">
      <p class="cfp-panel__meta">
        Vol.&thinsp;{{ next_call_issue.volume }}, No.&thinsp;{{ next_call_issue.number }}
        {% if next_call_issue.publication_date %}
          &ensp;&middot;&ensp;Expected {{ next_call_issue.publication_date | date: "%B %Y" }}
        {% endif %}
      </p>

      <h2 class="cfp-panel__title">{{ next_call_issue.title }}</h2>

      <p class="cfp-panel__topic">
        <strong>Topic:</strong>
        {% if next_call_issue.theme %}
          {{ next_call_issue.theme }}
        {% else %}
          Topic not yet announced
        {% endif %}
      </p>

      {% if next_call_issue.deadline %}
        <p class="cfp-panel__deadline"><strong>Submission deadline:</strong> {{ next_call_issue.deadline | date: "%B %-d, %Y" }}</p>
      {% endif %}

      {% if next_call_issue.description %}
        <p class="cfp-panel__description">{{ next_call_issue.description }}</p>
      {% endif %}

      <div class="cfp-panel__actions">
        <a class="btn btn--primary" href="{{ '/submit/' | relative_url }}">Go to Submit Page</a>
        <a class="btn btn--outline" href="{{ next_call_issue.url | relative_url }}">View Issue Details</a>
      </div>
    </section>
  {% else %}
    <section class="cfp-panel">
      <h2 class="cfp-panel__title">No open call right now</h2>
      <p class="cfp-panel__description">There is currently no issue with a future submission deadline.</p>
      <div class="cfp-panel__actions">
        <a class="btn btn--primary" href="{{ '/submit/' | relative_url }}">Go to Submit Page</a>
        <a class="btn btn--outline" href="{{ '/issues/' | relative_url }}">Browse Issues</a>
      </div>
    </section>
  {% endif %}
</div>
