---
marp: true
size: 16:9
---

<style>
.two-columns {
  display: flex;
  gap: 2rem;
  align-items: center;
}
.two-columns > * {
  flex: 1;
}
.left-column {
  padding-bottom: 50px;
}
</style>


# Setup

## GitHub - https://github.com/signup

## Dynatrace - https://www.dynatrace.com/signup

## Replit - https://replit.com/signup

---

<div class="two-columns">

<div class="left-column">
 
# The App
 
## https://bit.ly/practical-app

</div>

<div>

![](https://raw.githubusercontent.com/JoyfulProgramming/nerds_observability_course/c48c5c76beeabe2e3cd526c6d7cc910ac12ecc37/images/00_replit__kingofkerning__fix_bugs_20x_faster.png)

</div>

</div>

https://replit.com/@kingofkerning/Fix-Bugs-20x-Faster

---


<div class="two-columns">

<div class="left-column">
 
# Working Pattern

## https://bit.ly/upload-working

`MonaLisa.fcjson`

</div>

<div>

![](https://cdn.githubraw.com/JoyfulProgramming/nerds_observability_course/be1c1e3e88db09cc7f7152d378b65a6e717acfde/images/01_pattern_good_mona_lisa.png)

</div>

</div>

https://github.com/JoyfulProgramming/nerds_observability_course/blob/be1c1e3e88db09cc7f7152d378b65a6e717acfde/downloads/MonaLisa.fcjson

---

<div class="two-columns">

<div class="left-column">
 
# Failing Pattern

## https://bit.ly/upload-defect

`Puffins.fcjson`

</div>

<div>

![](https://cdn.githubraw.com/JoyfulProgramming/nerds_observability_course/be1c1e3e88db09cc7f7152d378b65a6e717acfde/images/01_pattern_bad_puffins.png)

</div>

</div>

https://github.com/JoyfulProgramming/nerds_observability_course/blob/be1c1e3e88db09cc7f7152d378b65a6e717acfde/downloads/Puffins.fcjson

---

![bg contain](https://cdn.githubraw.com/JoyfulProgramming/nerds_observability_course/be1c1e3e88db09cc7f7152d378b65a6e717acfde/images/00_five_steps_to_observable_software.png)


---

# <!-- fit --> Cycle 1 - Explore

---

# Step 1 - Question

## Step 1a - Hypotheses

Incorrect image format

ImageMagick is installed incorrectly

Pattern is too small or too big

---

# Step 1 - Question

## Step 1b - Ranked Hypotheses

1. Pattern is too small or too big - **most likely**
2. Incorrect image format
3. ImageMagick is installed incorrectly - **least likely**

---

# Step 1 - Question

## Step 1c - Create Question

Hypothesis #1 - Pattern is too small or too big.

### Question: Do the errors only happen on just one size of image?

---

# Step 2 - Decide

## Structure

1. **Event** to capture
2. **Filter** to restrict
3. **Group** to show correlations
4. **Attributes** to view

---

# Step 2 - Decide

## Actual

1. **Event** `Pattern#add_border_to_preview` called
2. **Filter by** none
3. **Group by** none
4. **Attributes** `pattern.width`, `pattern.height`, `error`

---
# Step 2 - Decide

## In SQL

```sql
SELECT pattern.width, pattern.height, error
FROM events
WHERE event.name == 'Pattern#add_border_to_preview called'
```

---

# Step 3 - Build

## Configure OTel Logging

```bash
git fetch                 # Get latest commits
git cherry-pick 2d0906a   # Set up structured logging
bundle install            # Install dependencies

git show HEAD -w          # View changes (optional)
```

---

# Step 3 - Build

## Log Pattern Height and Width


```bash
git cherry-pick 4330154   # Apply the change

git show HEAD -w          # View changes (optional)
```

---

# Step 3 - Build

## Connect Dynatrace

Create environment variables `DYNATRACE_API_TOKEN` and `DYNATRACE_APP_ID`.

Populate them with credentials from Dynatrace.

---

# Step 3 - Build

## Simulate Users

Run `bin/hammer`.

---

# Step 4 - Use

## Query For Events

Query for `Pattern#add_border_to_preview` events in Dynatrace.

---

# Step 4 - Use

## Select Log Attributes

Show `error`, `pattern.height`, `pattern.width` in the table.

---

# Step 5 - Reflect

## Conclusion

All errors happen when width is greater than height.

## A New Direction

Related to **orientation** - landscape, square, portrait.

---

# <!-- fit --> Cycle 2 - Orientation

---

# Step 1 - Question

## Hypothesis

Specific orientations cause the errors.

## Form a Question

Do all errors happen with a specific orientation?

---

# Step 2 - Define Data

## The Power of `GROUP BY`

`GROUP BY` is powerful to surface **correlations** between attributes.

**Question:** Do all errors happen with a specific orientation?

**Answer:** Correlate **errors** with **orientation**.

---

# Step 2 - Define Data

## Dimensions

1. **Event** `Pattern#add_border_to_preview` called
2. **Filter by** none
3. **Group by** `error`, `pattern.orientation`
4. **Attributes** `pattern.width`, `pattern.height`, `error`

---

# Step 2 - Define Data

## SQL

```sql
SELECT pattern.width, pattern.height, error
FROM events
WHERE event.name == 'Pattern#add_border_to_preview called'
GROUP BY error, pattern.orientation
```


---

# Step 3 - Build

## Log orientation

```bash
git cherry-pick b015569   # Add orientation attribute to logs

git show HEAD -w          # View changes (optional)
```

---

# Step 3 - Build

## Simulate Users

```bash
bin/hammer
```

---

# Step 4 - Use

## Wait For Logs From Latest Run

---

# Step 4 - Use

## Group in Dynatrace

Top right next to `Run Query`: `Dots -> Edit DQL Query`

DQL:

```
fetch logs
| filter matchesValue(event.name, "app.pattern.border_added_to_preview")
| summarize count(), by: { error, app.pattern.orientation }
```

---

# Step 5 - Reflect

## Three combinations

Square and portrait patterns **always work**.

Landscape patterns **always error**.

---

# Step 5 - Reflect

## Question Answered

> Q: Do all errors happen with a specific orientation?
>
> A: Yes, landscape.


---

# Fix Defect

```bash
git cherry-pick e8d138e   # Add landscape configuration

git show HEAD -w          # View changes (optional)
```

---

# Validate Fix

## Upload Puffins.fcjson

Link to download: https://bit.ly/upload-defect

## ✅ Fixed!

---

# <!-- fit -->  🎉 Congratulations!

---

# Recap

## Initial State

App crashes on `Puffins.fcjson`, works on `MonaLisa.fcjson`.

Generic error logs show nothing useful.

---

# Recap

## Cycle 1

- **Step 1: Question** - "Do errors only happen on one size of image?"
- **Step 2: Data** - "Pattern#add_border_to_preview called" with height and width.
- **Step 3: Build** - Added logging of attributes.
- **Step 4: Use** - Queried logs, added columns, sorted by error.
- **Step 5: Reflect** - Most errors had width > height. Orientation?

---

# Recap

## Cycle 2

- **Step 1: Question** - "Do all errors happen with a specific orientation?"
- **Step 2: Data** - Need `app.pattern.orientation` attribute
- **Step 3: Build** - Add `app.pattern.orientation` attribute to the code
- **Step 4: Use** - Grouped by error + orientation
- **Step 5: Reflect** - **🎉 Answer found - Every error was landscape**.
- **Fix and Validate** - Add landscape configuration, test.


---

# Takeaways

## What is Observability?

Observability is **NOT logs, traces and metrics**.

Observability is **understanding your app in production by answering novel questions**.

---

# Takeaways

## Observability is incremental and iterative.

### 😭 "Add Logging" Jira ticket

### 😍 Build enough instrumentation to answer your question

---

# Takeaways

## Insufficient data leads to guessing

> If you can't make decisions on data, make decisions to generate data.
> 
> Kent Beck

---

# Takeaways

## Stack traces are not enough

Old, dated technology designed for 1970s software running on a single processor.

We need an **event history** prior to the defect.

---

# Takeaways

## `GROUP BY` is powerful

Shrinks down huge numbers of data into a digestable summary.

Helps us see correlations between attributes.

---

# I Want More!


## 1. [Team Coaching - ~~$2900~~ $550](https://www.notion.so/Practical-Observability-Workshop-2ab4aa4e927f8100b738e12bb54433e3?pvs=21)
## 2. [Solo Coaching - ~~$800~~ $150](https://www.notion.so/Practical-Observability-Workshop-2ab4aa4e927f8100b738e12bb54433e3?pvs=21)
## 3. [Course - $100](https://www.notion.so/Practical-Observability-Workshop-2ab4aa4e927f8100b738e12bb54433e3?pvs=21)

---

# I Want More!

## 1. Team Coaching - ~~$2900~~ $550

- **3 hour intensive workshop** tailored to your tech stack and real production challenges
- **Custom instrumentation examples** for your specific architecture
- **Team playbook** documenting your new observability strategy
- **30 day Slack support** for implementation questions
- **Follow-up session** (60 minutes) to review progress and refine approach

Full price: ~~$2900~~ - **First 4 Clients: $550**

### Action: [Book Team Coaching Session](https://tr.ee/f87xPvPMis)

---

# I Want More!

## 2. Solo Coaching - ~~$800~~ $150

- **90 minute intensive 1-on-1 session** focused entirely on your specific challenges
- **Live debugging walkthrough** of a real production issue from your system
- **Personalized instrumentation strategy** tailored to your tech stack and domain
- **Custom code examples** you can apply immediately
- **Recording of the session** for future reference and team sharing
- **Follow-up via email** for clarification questions within 7 days

Full price: ~~$800~~ - **First 4 Clients: $150**

### Action: [Book A Solo Coaching Call](https://tr.ee/f87xPvPMis)

---

# I Want More!

## 3. Course - ~~$200~~ $100

I’m building a course.

It’s in progress and I need your help!

### Action: [Tell me what you want.](https://forms.gle/kJP7cdkakjwqU9ms9)

**8 questions, takes 3 minutes.**

---

# <!-- fit -->  🙏 Thank You!

## More Courses:

## https://www.youtube.com/@joyfulprogramming
