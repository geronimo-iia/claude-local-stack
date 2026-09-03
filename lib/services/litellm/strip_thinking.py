from litellm.integrations.custom_logger import CustomLogger


class StripThinkingHook(CustomLogger):
    """Strip 'thinking' param before routing to models that don't support it."""

    async def async_pre_call_hook(self, user_api_key_dict, cache, data, call_type):
        data.pop("thinking", None)
        return data

    def pre_call_hook(self, user_api_key_dict, cache, data, call_type):
        data.pop("thinking", None)
        return data


proxy_handler_instance = StripThinkingHook()
