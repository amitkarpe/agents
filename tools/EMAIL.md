---
type: Playbook
title: Reviewable Email Drafts and Uncertain Sends
status: candidate
confidence: medium
scope: Provider-neutral email authority and payload handling
review_after: 2027-01-28
tags: [email, authority, attachments, uncertainty]
---

# Reviewable Email Drafts and Uncertain Sends

Drafting and sending are separate actions. Default to a reviewable draft unless
the owner already authorized the exact send or a clearly bounded class of
sends. Local fixed-recipient allowlists, confirmation requirements and approved
provider routes can be stricter; generic guidance never bypasses them.

## Freeze the reviewed content

Before sending, verify:

- intended sender identity and provider/account;
- exact To, Cc and Bcc recipients, including reply/forward expansion;
- subject and rendered plain-text/HTML body;
- every attachment's bytes, filename, media type and recipient suitability;
- secrets, private identifiers, hidden spreadsheet/document content and links;
- whether existing approval covers this recipient/content/attachment combination.

A path or a claimed filename does not prove an attachment exists or contains
the reviewed content. Preserve a private draft and content/version binding when
approval and execution happen separately. If material content or recipients
change after review, reconcile approval before sending.

## Build a payload without quoting surprises

Use a real multiline body file. Literal `\n` text is not a newline unless the
chosen encoder explicitly interprets it. A provider-neutral preparation example:

```bash
jq -n --arg to "$approved_recipient" --arg subject "$approved_subject" \
  --rawfile text "$reviewed_body_file" \
  '{to: [$to], subject: $subject, text: $text}' > draft.json
jq -e '(.to | type == "array" and length > 0)
       and (.subject | type == "string")
       and (.text | type == "string")' draft.json >/dev/null
```

This constructs a draft; it does not send it. Confirm the provider's current
schema before use. The pinned source used an AgentMail-style API; field names,
attachment encoding and send endpoints are provider-specific, not a universal
email protocol.

If that contract requires base64 attachment content, encode the **reviewed**
file, preserve its intended filename/media type, and validate the final JSON.
For example, in an already authorized private preparation directory:

```bash
base64 < "$reviewed_attachment" | tr -d '\n' > attachment.b64
jq --arg filename "$approved_filename" --arg content_type "$approved_media_type" \
  --rawfile content attachment.b64 \
  '.attachments = [{filename: $filename, content_type: $content_type,
                     content: $content}]' draft.json > draft-with-attachment.json
```

Base64 is not encryption. Protect/remove these temporary copies according to
the owning retention policy. Do not print full payloads or attachments into a
shared transcript. Recheck final provider schema, decoded attachment bytes and
size limits before a send.

## Authentication and execution

Use the owner's approved mail helper/secret store and intended identity.
Do not source an entire environment file, print tokens, copy another user's
credentials or place bearer tokens in process arguments. A missing helper or
expired authentication is a blocker; it is not permission to invent a route.

Send once through the approved provider method, with an idempotency key only
where its documented semantics support the operation. Record the request
correlation, HTTP/provider status and message ID without credential headers or
private body content. API acceptance proves the provider accepted a message,
not inbox delivery, reading or recipient approval.

## Reconcile uncertainty before retry

A timeout, interrupted client or lost response may follow a successful send.
Classify it as UNKNOWN, preserve request/content identity, and use the approved
outbox/message/status readback to determine whether it was accepted. An empty
local log or client error is not proof that nothing was sent.

Do not issue another POST merely because no message ID reached the terminal.
If readback cannot resolve the ambiguity, report the exact uncertainty and
required owner/provider action. Delivery failure after acceptance is a separate
state; apply the provider's documented handling and owner authority rather
than automatically sending a second copy.

## Citations

- [Pinned email workflow provenance](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/email.md)
- [jq manual](https://jqlang.org/manual/)
- [AgentMail documentation](https://docs.agentmail.to/)
