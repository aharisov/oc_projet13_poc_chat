package com.yourcaryourway.chatpoc.model;

import java.time.Instant;

public class ChatMessage {

    private String conversationId;
    private String sender;
    private String role;
    private String content;
    private Instant timestamp;

    public ChatMessage() {
    }

    public ChatMessage(
            String conversationId,
            String sender,
            String role,
            String content,
            Instant timestamp) {
        this.conversationId = conversationId;
        this.sender = sender;
        this.role = role;
        this.content = content;
        this.timestamp = timestamp;
    }

    public String getConversationId() {
        return conversationId;
    }

    public void setConversationId(String conversationId) {
        this.conversationId = conversationId;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Instant getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Instant timestamp) {
        this.timestamp = timestamp;
    }
}