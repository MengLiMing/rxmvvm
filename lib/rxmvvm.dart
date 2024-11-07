library rxmvvm;

import 'dart:async';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

/// consumer
part 'core/consumer/retrieve.dart';
part 'core/consumer/single.dart';
part 'core/consumer/view_model_consumer.dart';
part 'core/consumer/view_model_consumer_state_mixin.dart';
part 'core/consumer/view_model_container.dart';

/// dispose_bag
part 'core/dispose_bag/dispose_bag_mixin.dart';
part 'core/dispose_bag/dispose_bag_provider.dart';
part 'core/dispose_bag/dispose_extension.dart';

/// event_bus
part 'core/event_bus/event_bus.dart';
part 'core/event_bus/event_bus_mixin.dart';

/// extension
part 'core/extensions/context_extension.dart';
part 'core/extensions/list_extension.dart';
part 'core/extensions/observable_extension.dart';
part 'core/extensions/rx_extension.dart';
part 'core/extensions/sync_extension.dart';

/// logger
part 'core/logger/logger.dart';

/// provider
part 'core/provider/view_model_provider.dart';

/// utils
part 'core/utils/stream_builder_factory.dart';

/// view_model
part 'core/view_model/context_provider_mixin.dart';
part 'core/view_model/dispatch_action_mixin.dart';
part 'core/view_model/view_model.dart';
