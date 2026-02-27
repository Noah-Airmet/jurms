---
layout: default
title: The Forum
permalink: /forum/
---

<div class="container">

  <div class="page-header">
    <h1 class="page-header__title">The Forum</h1>
    <p class="page-header__lead">
      Short pieces, reflections, and voices from the community — reviewed by our editors and published here for everyone to read.
    </p>
  </div>

  {% assign all_posts = site.board_posts | sort: 'date' | reverse %}

  {% if all_posts.size > 0 %}
    <div class="board-grid">
      {% for post in all_posts %}
        <a href="{{ post.url | relative_url }}" class="board-card">
          {% if post.header_image %}
            <div class="board-card__media">
              <img src="{{ post.header_image | relative_url }}"
                   alt="{{ post.header_image_alt | default: post.title | escape }}"
                   class="board-card__image"
                   loading="lazy">
            </div>
          {% endif %}
          <div class="board-card__content">
            <p class="board-card__meta">
              {{ post.date | date: "%B %d, %Y" }}
            </p>
            <p class="board-card__title">{{ post.title }}</p>
            {% if post.excerpt %}
              <p class="board-card__excerpt">{{ post.excerpt | strip_html | truncatewords: 20 }}</p>
            {% endif %}
            <p class="board-card__author">{{ post.author }}</p>
          </div>
        </a>
      {% endfor %}
    </div>
  {% else %}
    <p style="color: var(--c-text-muted); padding: var(--sp-8) 0; font-style: italic;">
      No posts yet — check back soon, or <a href="{{ '/submit/' | relative_url }}">submit something</a> to the Forum.
    </p>
  {% endif %}

</div>
