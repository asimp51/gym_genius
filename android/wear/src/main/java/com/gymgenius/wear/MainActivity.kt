package com.gymgenius.wear

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.wear.compose.material.*
import androidx.wear.compose.navigation.SwipeDismissableNavHost
import androidx.wear.compose.navigation.composable
import androidx.wear.compose.navigation.rememberSwipeDismissableNavController
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            GymGeniusWearApp()
        }
    }
}

// -- Theme Colors ----------------------------------------------------------

private val DarkBg = Color(0xFF0A0E1A)
private val CardBg = Color(0xFF111827)
private val Accent = Color(0xFF3B82F6)
private val Success = Color(0xFF10B981)
private val Warning = Color(0xFFF59E0B)
private val Error = Color(0xFFF43F5E)
private val TextPrimary = Color(0xFFF2F2F2)
private val TextSecondary = Color(0xFF94A3B8)
private val TextTertiary = Color(0xFF64748B)

// -- App -------------------------------------------------------------------

@Composable
fun GymGeniusWearApp() {
    val navController = rememberSwipeDismissableNavController()

    MaterialTheme(
        colors = Colors(
            primary = Accent,
            secondary = Success,
            background = DarkBg,
            surface = CardBg,
            onPrimary = Color.White,
            onSecondary = Color.White,
            onBackground = TextPrimary,
            onSurface = TextPrimary,
            onSurfaceVariant = TextSecondary,
            error = Error,
            onError = Color.White,
        )
    ) {
        SwipeDismissableNavHost(
            navController = navController,
            startDestination = "home"
        ) {
            composable("home") {
                HomeScreen(
                    onStartWorkout = { navController.navigate("templates") },
                    onViewHeartRate = { navController.navigate("heartrate") }
                )
            }
            composable("templates") {
                TemplateListScreen(
                    onSelectTemplate = { navController.navigate("workout") }
                )
            }
            composable("workout") {
                ActiveWorkoutScreen(
                    onFinish = {
                        navController.popBackStack("home", false)
                        navController.navigate("summary")
                    }
                )
            }
            composable("summary") {
                WorkoutSummaryScreen(
                    onDone = { navController.popBackStack("home", false) }
                )
            }
            composable("heartrate") {
                HeartRateScreen()
            }
        }
    }
}

// -- Home Screen -----------------------------------------------------------

@Composable
fun HomeScreen(
    onStartWorkout: () -> Unit,
    onViewHeartRate: () -> Unit
) {
    val listState = rememberScalingLazyListState()

    Scaffold(
        timeText = { TimeText() },
        vignette = { Vignette(vignettePosition = VignettePosition.TopAndBottom) },
        positionIndicator = { PositionIndicator(scalingLazyListState = listState) }
    ) {
        ScalingLazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp),
            contentPadding = PaddingValues(
                top = 32.dp,
                bottom = 16.dp,
                start = 8.dp,
                end = 8.dp
            )
        ) {
            item {
                Text(
                    text = "GymGenius",
                    style = MaterialTheme.typography.title2.copy(
                        fontWeight = FontWeight.Bold,
                        color = Accent
                    ),
                    textAlign = TextAlign.Center
                )
            }

            item { Spacer(modifier = Modifier.height(4.dp)) }

            // Start Workout
            item {
                Chip(
                    onClick = onStartWorkout,
                    label = {
                        Text(
                            "Start Workout",
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    },
                    icon = {
                        Icon(
                            imageVector = androidx.compose.material.icons.Icons.Rounded.FitnessCenter,
                            contentDescription = null,
                            modifier = Modifier.size(24.dp)
                        )
                    },
                    colors = ChipDefaults.chipColors(
                        backgroundColor = Accent,
                        contentColor = Color.White
                    ),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            // Heart Rate
            item {
                Chip(
                    onClick = onViewHeartRate,
                    label = {
                        Text(
                            "Heart Rate",
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    },
                    icon = {
                        Icon(
                            imageVector = androidx.compose.material.icons.Icons.Rounded.Favorite,
                            contentDescription = null,
                            tint = Error,
                            modifier = Modifier.size(24.dp)
                        )
                    },
                    colors = ChipDefaults.secondaryChipColors(),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            // Today Stats
            item {
                Spacer(modifier = Modifier.height(4.dp))
            }
            item {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    MiniStatCard(
                        value = "4,823",
                        label = "Steps",
                        color = Accent,
                        modifier = Modifier.weight(1f)
                    )
                    MiniStatCard(
                        value = "312",
                        label = "Cal",
                        color = Warning,
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }
    }
}

@Composable
fun MiniStatCard(
    value: String,
    label: String,
    color: Color,
    modifier: Modifier = Modifier
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(CardBg)
            .padding(vertical = 8.dp, horizontal = 4.dp)
    ) {
        Text(
            text = value,
            style = MaterialTheme.typography.title3.copy(
                fontWeight = FontWeight.Bold,
                color = color
            ),
            maxLines = 1
        )
        Text(
            text = label,
            style = MaterialTheme.typography.caption3.copy(
                color = TextSecondary
            ),
            maxLines = 1
        )
    }
}

// -- Template List Screen --------------------------------------------------

@Composable
fun TemplateListScreen(onSelectTemplate: () -> Unit) {
    val listState = rememberScalingLazyListState()

    // Sample templates — in production these come from DataLayer sync.
    val templates = listOf(
        "Push Day" to "Chest, Shoulders, Triceps",
        "Pull Day" to "Back, Biceps",
        "Leg Day" to "Quads, Hamstrings, Calves",
        "Upper Body" to "Full Upper",
        "Full Body" to "All Muscle Groups"
    )

    Scaffold(
        timeText = { TimeText() },
        vignette = { Vignette(vignettePosition = VignettePosition.TopAndBottom) },
        positionIndicator = { PositionIndicator(scalingLazyListState = listState) }
    ) {
        ScalingLazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            contentPadding = PaddingValues(top = 32.dp, bottom = 16.dp, start = 8.dp, end = 8.dp)
        ) {
            item {
                Text(
                    "Select Workout",
                    style = MaterialTheme.typography.title3.copy(
                        fontWeight = FontWeight.SemiBold
                    )
                )
            }
            items(templates.size) { idx ->
                val (name, subtitle) = templates[idx]
                Chip(
                    onClick = onSelectTemplate,
                    label = {
                        Text(name, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    },
                    secondaryLabel = {
                        Text(
                            subtitle,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            style = MaterialTheme.typography.caption3
                        )
                    },
                    colors = ChipDefaults.secondaryChipColors(),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}

// -- Active Workout Screen -------------------------------------------------

@Composable
fun ActiveWorkoutScreen(onFinish: () -> Unit) {
    var elapsedSeconds by remember { mutableIntStateOf(0) }
    var currentSetIndex by remember { mutableIntStateOf(0) }
    var isResting by remember { mutableStateOf(false) }
    var restSeconds by remember { mutableIntStateOf(0) }
    var heartRate by remember { mutableIntStateOf(72) }

    val totalSets = 4
    val exerciseName = "Bench Press"
    val currentWeight = "185 lbs"
    val currentReps = "8 reps"

    // Workout timer
    LaunchedEffect(Unit) {
        while (true) {
            delay(1000)
            elapsedSeconds++
            // Simulate heart rate variation
            heartRate = (65..145).random()
        }
    }

    // Rest timer
    LaunchedEffect(isResting) {
        if (isResting) {
            restSeconds = 90
            while (restSeconds > 0) {
                delay(1000)
                restSeconds--
            }
            isResting = false
            // Haptic feedback would go here via Vibrator service.
        }
    }

    val listState = rememberScalingLazyListState()

    Scaffold(
        timeText = { TimeText() }
    ) {
        ScalingLazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            contentPadding = PaddingValues(top = 24.dp, bottom = 16.dp, start = 8.dp, end = 8.dp)
        ) {
            // Workout timer
            item {
                val minutes = elapsedSeconds / 60
                val seconds = elapsedSeconds % 60
                Text(
                    text = "%02d:%02d".format(minutes, seconds),
                    style = MaterialTheme.typography.title2.copy(
                        fontWeight = FontWeight.Bold,
                        color = Accent
                    )
                )
            }

            // Heart rate
            item {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center,
                    modifier = Modifier.padding(vertical = 2.dp)
                ) {
                    Icon(
                        imageVector = androidx.compose.material.icons.Icons.Rounded.Favorite,
                        contentDescription = "Heart rate",
                        tint = heartRateColor(heartRate),
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "$heartRate",
                        style = MaterialTheme.typography.title3.copy(
                            fontWeight = FontWeight.Bold,
                            color = heartRateColor(heartRate)
                        )
                    )
                    Spacer(modifier = Modifier.width(2.dp))
                    Text(
                        text = "BPM",
                        style = MaterialTheme.typography.caption3.copy(
                            color = TextSecondary
                        )
                    )
                }
            }

            // Rest timer overlay
            if (isResting) {
                item {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier
                            .clip(RoundedCornerShape(16.dp))
                            .background(CardBg)
                            .padding(16.dp)
                            .fillMaxWidth()
                    ) {
                        Text(
                            "REST",
                            style = MaterialTheme.typography.title3.copy(
                                color = Warning,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "%d:%02d".format(restSeconds / 60, restSeconds % 60),
                            style = MaterialTheme.typography.display1.copy(
                                fontWeight = FontWeight.Bold,
                                color = TextPrimary
                            )
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        CompactChip(
                            onClick = { isResting = false },
                            label = { Text("Skip", style = MaterialTheme.typography.caption1) },
                            colors = ChipDefaults.secondaryChipColors()
                        )
                    }
                }
            }

            // Current exercise
            if (!isResting) {
                item {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier
                            .clip(RoundedCornerShape(16.dp))
                            .background(CardBg)
                            .padding(12.dp)
                            .fillMaxWidth()
                    ) {
                        Text(
                            exerciseName,
                            style = MaterialTheme.typography.title3.copy(
                                fontWeight = FontWeight.SemiBold
                            ),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            "Set ${currentSetIndex + 1} of $totalSets",
                            style = MaterialTheme.typography.body2.copy(
                                color = TextSecondary
                            )
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            "$currentWeight  |  $currentReps",
                            style = MaterialTheme.typography.caption1.copy(
                                color = Accent
                            )
                        )
                    }
                }

                // Complete set button
                item {
                    Chip(
                        onClick = {
                            if (currentSetIndex < totalSets - 1) {
                                currentSetIndex++
                                isResting = true
                            } else {
                                onFinish()
                            }
                        },
                        label = {
                            Text(
                                if (currentSetIndex < totalSets - 1) "Complete Set" else "Finish",
                                style = MaterialTheme.typography.button.copy(
                                    fontWeight = FontWeight.SemiBold
                                )
                            )
                        },
                        colors = ChipDefaults.chipColors(
                            backgroundColor = if (currentSetIndex < totalSets - 1) Success else Accent,
                            contentColor = Color.White
                        ),
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }

            // Finish button
            item {
                CompactChip(
                    onClick = onFinish,
                    label = { Text("End Workout") },
                    colors = ChipDefaults.chipColors(
                        backgroundColor = Error.copy(alpha = 0.2f),
                        contentColor = Error
                    )
                )
            }
        }
    }
}

// -- Workout Summary Screen ------------------------------------------------

@Composable
fun WorkoutSummaryScreen(onDone: () -> Unit) {
    val listState = rememberScalingLazyListState()

    Scaffold(
        timeText = { TimeText() }
    ) {
        ScalingLazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            contentPadding = PaddingValues(top = 32.dp, bottom = 16.dp, start = 8.dp, end = 8.dp)
        ) {
            item {
                Icon(
                    imageVector = androidx.compose.material.icons.Icons.Rounded.CheckCircle,
                    contentDescription = null,
                    tint = Success,
                    modifier = Modifier.size(36.dp)
                )
            }
            item {
                Text(
                    "Workout Complete!",
                    style = MaterialTheme.typography.title3.copy(
                        fontWeight = FontWeight.Bold
                    ),
                    textAlign = TextAlign.Center
                )
            }
            item { Spacer(modifier = Modifier.height(8.dp)) }

            // Stats
            item {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    MiniStatCard(value = "42:15", label = "Duration", color = Accent, modifier = Modifier.weight(1f))
                    MiniStatCard(value = "12", label = "Sets", color = Success, modifier = Modifier.weight(1f))
                }
            }
            item {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    MiniStatCard(value = "4,200", label = "Volume", color = Warning, modifier = Modifier.weight(1f))
                    MiniStatCard(value = "285", label = "Cal", color = Error, modifier = Modifier.weight(1f))
                }
            }
            item {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    MiniStatCard(value = "118", label = "Avg HR", color = Error, modifier = Modifier.weight(1f))
                    MiniStatCard(value = "152", label = "Max HR", color = Error, modifier = Modifier.weight(1f))
                }
            }

            item { Spacer(modifier = Modifier.height(8.dp)) }
            item {
                Chip(
                    onClick = onDone,
                    label = { Text("Done") },
                    colors = ChipDefaults.chipColors(
                        backgroundColor = Accent,
                        contentColor = Color.White
                    ),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}

// -- Heart Rate Screen -----------------------------------------------------

@Composable
fun HeartRateScreen() {
    var heartRate by remember { mutableIntStateOf(72) }

    LaunchedEffect(Unit) {
        while (true) {
            delay(1500)
            heartRate = (58..95).random()
        }
    }

    val hrColor = heartRateColor(heartRate)
    val zoneName = heartRateZoneName(heartRate)

    Scaffold(
        timeText = { TimeText() }
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = androidx.compose.material.icons.Icons.Rounded.Favorite,
                contentDescription = "Heart",
                tint = hrColor,
                modifier = Modifier.size(32.dp)
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "$heartRate",
                style = MaterialTheme.typography.display1.copy(
                    fontWeight = FontWeight.Bold,
                    color = hrColor
                )
            )
            Text(
                text = "BPM",
                style = MaterialTheme.typography.body1.copy(
                    color = TextSecondary
                )
            )
            Spacer(modifier = Modifier.height(8.dp))
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(hrColor.copy(alpha = 0.15f))
                    .padding(horizontal = 12.dp, vertical = 4.dp)
            ) {
                Text(
                    text = zoneName,
                    style = MaterialTheme.typography.caption1.copy(
                        color = hrColor,
                        fontWeight = FontWeight.SemiBold
                    )
                )
            }
        }
    }
}

// -- Helpers ---------------------------------------------------------------

private fun heartRateColor(bpm: Int): Color = when {
    bpm < 100 -> Success
    bpm < 120 -> Color(0xFF22D3EE)
    bpm < 140 -> Warning
    bpm < 160 -> Color(0xFFf97316)
    else -> Error
}

private fun heartRateZoneName(bpm: Int): String = when {
    bpm < 100 -> "Rest"
    bpm < 114 -> "Warm Up"
    bpm < 133 -> "Fat Burn"
    bpm < 162 -> "Cardio"
    else -> "Peak"
}
