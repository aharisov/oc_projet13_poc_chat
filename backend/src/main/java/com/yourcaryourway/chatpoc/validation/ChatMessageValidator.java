package com.yourcaryourway.chatpoc.validation;

import org.springframework.stereotype.Component;

import com.yourcaryourway.chatpoc.model.ChatMessage;

@Component
public class ChatMessageValidator {

    private static final int MAX_MESSAGE_LENGTH = 1000;

    public boolean isValid(ChatMessage message) {
        if (message == null) {
            return false;
        }

        String content = message.getContent();

        if (content == null || content.isBlank()) {
            return false;
        }

        return content.length() <= MAX_MESSAGE_LENGTH;
    }
}